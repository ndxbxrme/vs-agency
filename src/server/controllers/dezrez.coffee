'use strict'

module.exports = (ndx) ->
  if process.env.REZI_ID and process.env.REZI_SECRET
    pageSize = 
      pageSize:2000
    ndx.app.get '/api/dezrez/property/:id', (req, res, next) ->
      ndx.dezrez.get 'property/{id}', pageSize, id:req.params.id, (err, body) ->
        if not err
          res.json body
        else
          next err
    ndx.app.get '/api/dezrez/property/:id/:param1', (req, res, next) ->
      ndx.dezrez.get "property/{id}/#{req.params.param1}", pageSize, id:req.params.id, (err, body) ->
        if not err
          res.json body
        else
          next err
    ndx.app.get '/api/dezrez/property/:id/:param1/:param2', (req, res, next) ->
      ndx.dezrez.get "property/{id}/#{req.params.param1}/#{req.params.param2}", pageSize, id:req.params.id, (err, body) ->
        if not err
          res.json body
        else
          next err
    ndx.app.get '/api/dezrez/role/:id', (req, res, next) ->
      ndx.dezrez.get 'role/{id}', pageSize, id:req.params.id, (err, body) ->
        if not err
          res.json body
        else
          next err
    ndx.app.get '/api/dezrez/role/:id/:param1', (req, res, next) ->
      ndx.dezrez.get "role/{id}/#{req.params.param1}", pageSize, id:req.params.id, (err, body) ->
        if not err
          res.json body
        else
          next err
    ndx.app.get '/api/dezrez/offer/:id', (req, res, next) ->
      ndx.dezrez.get 'offer/{id}', pageSize, id:req.params.id, (err, body) ->
        if not err
          res.json body
        else
          next err