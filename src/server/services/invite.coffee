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
        throw 'out of date'
      user = JSON.parse json
    user
  ndx.app.post '/invite/accept', (req, res, next) ->
    try
      user = parseCode req.body.code
    catch e
      return next e
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
  ndx.app.post '/api/get-invite-code', (req, res, next) ->
    text = JSON.stringify req.body
    text += '||' + new Date().valueOf()
    text = encodeURIComponent(crypto.Rabbit.encrypt(text, ndx.settings.SESSION_SECRET).toString())
    res.end text