'use strict'

module.exports = (ndx) ->
  ndx.app.get '/api/users', ndx.authenticate(), (req, res, next) ->
    res.json ndx.database.exec("SELECT _id, displayName, local->email as email, roles FROM #{ndx.settings.USER_TABLE}")