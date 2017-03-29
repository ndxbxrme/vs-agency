'use strict'

module.exports = (ndx) ->
  ndx.app.post '/api/milestone/start', ndx.authenticate(), (req, res, next) ->
    ndx.milestone.processActions 'Start', req.body.actions, req.body.roleId
    res.end 'OK'
  ndx.app.post '/api/milestone/complete', ndx.authenticate(), (req, res, next) ->
    ndx.milestone.processActions 'Complete', req.body.actions, req.body.roleId
    res.end 'OK'