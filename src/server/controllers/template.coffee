'use strict'
fs = require 'fs'

module.exports = (ndx) ->
  fn2h = (name) ->
    name = name.replace /[-_]+/gi, ' '
    name = name.replace /\.\w+/g, ''
    name = name.replace /(\w)(\w+)/g, (all, letter, rest) ->
      letter.toUpperCase() + rest.toLowerCase()
    name
  ndx.app.post '/api/template/email', ndx.authenticate(), (req, res, next) ->
    fs.readdir './views', (err, items) ->
      if err
        next err
      else
        outitems = []
        for item in items
          if item.indexOf 'vsinternal' is -1
            outitems.push
              name: fn2h item
              filename: item
        res.json
          total: outitems.length
          items: outitems
          page: 1
          pageSize: outitems.length
  ndx.app.post '/api/template/sms', ndx.authenticate(), (req, res, next) ->