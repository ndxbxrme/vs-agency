'use strict'

crypto = require 'crypto-js'

module.exports = (ndx) ->
  parseCode = (code) ->
    decrypted = ''
    user = null
    decrypted = crypto.Rabbit.decrypt(code, ndx.settings.SESSION_SECRET).toString(crypto.enc.Utf8)
    decrypted.replace /(.*)\|\|(\d+$)/, (all, json, date) ->
      #check date
      if +date < new Date().valueOf() - (3 * 24 * 60 * 60 * 1000)
        throw 'Token has expired'
      user = JSON.parse json
    user
  ndx.app.post '/invite/accept', (req, res, next) ->
    try
      user = parseCode req.body.code
    catch e
      return next e
    userCheck = ndx.database.exec "SELECT * FROM #{ndx.settings.USER_TABLE} WHERE local->email=?", [user.email]
    if userCheck and userCheck.length
      return next 'User already exists'
    newUser = 
      displayName: req.body.user.displayName
      local:
        email: user.email
        password: ndx.generateHash req.body.user.password
      roles: {}
    newUser.roles[user.role] = {}
    ndx.database.exec "INSERT INTO #{ndx.settings.USER_TABLE} VALUES ?", [newUser]
    res.end 'OK'
  ndx.app.get '/invite/:code', (req, res, next) ->
    try
      user = parseCode req.params.code
    catch e
      return next e
    res.redirect "/invited?#{encodeURIComponent(req.params.code)}"
  ndx.app.post '/api/get-invite-code', ndx.authenticate(['admin', 'superadmin']), (req, res, next) ->
    userCheck = ndx.database.exec "SELECT * FROM #{ndx.settings.USER_TABLE} WHERE local->email=?", [req.body.email]
    if userCheck and userCheck.length
      return next 'User already exists'
    text = JSON.stringify req.body
    text += '||' + new Date().valueOf()
    text = encodeURIComponent(crypto.Rabbit.encrypt(text, ndx.settings.SESSION_SECRET).toString())
    ndx.database.select 'emailtemplates',
      name: 'User Invite'
    , (templates) ->
      if templates and templates.length
        ndx.gmail.send
          template: templates[0]._id + '.jade'
          to: req.body.email
          subject: templates[0].subject
          code: text
          
    res.end text