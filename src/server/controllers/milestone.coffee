'use strict'

module.exports = (ndx) ->
  ndx.app.post '/api/milestone/start', ndx.authenticate(), (req, res, next) ->
  
  ndx.app.post '/api/milestone/complete', ndx.authenticate(), (req, res, next) ->