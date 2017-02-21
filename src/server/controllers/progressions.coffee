'use strict'

module.exports = (ndx) ->
  ndx.app.get '/api/progressions', ndx.authenticate(), (req, res, next) ->
    res.json ndx.database.exec("SELECT * FROM progressions")
  ndx.app.post '/api/progression', ndx.authenticate(['admin', 'superadmin']), (req, res, next) ->
    ndx.database.upsert 'progressions', req.body, '_id=?', [req.body._id]
    res.send 'OK'