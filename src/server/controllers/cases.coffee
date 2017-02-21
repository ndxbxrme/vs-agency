'use strict'

module.exports = (ndx) ->
  if process.env.REZI_ID and process.env.REZI_SECRET
    pageSize =
      pageSize: 2000
    ndx.app.get '/api/property/:roleId', ndx.authenticate(), (req, res, next) ->
      property = ndx.database.exec 'SELECT * FROM properties WHERE roleId=?', [+req.params.roleId]
      if property and property.length
        res.json property[0]
      else
        property =
          roleId: +req.params.roleId
        ndx.dezrez.get 'role/{id}/vendors', null, id:req.params.roleId, (err, body) ->
          if not err
            property.vendors = body
            property.vendor = body.Name
            ndx.dezrez.get 'role/{id}/offers', pageSize, id:req.params.roleId, (err, body) ->
              if not err
                for offer in body.Collection
                  if offer.Response.ResponseType.SystemName is 'Accepted'
                    ndx.dezrez.get 'offer/{id}', null, id:offer.Id, (err, body) ->
                      if not err
                        property.offer = body
                        property.purchaser = body.ApplicantGroup.Name
                        ndx.database.insert 'properties', property
                        res.json property
                      else
                        return next(err)
              else
                return next(err)
          else
            return next(err)
    ndx.app.post '/api/property/:roleId', ndx.authenticate(), (req, res, next) ->
      if req.body
        ndx.database.update 'properties', req.body, 'roleId=?', [req.body.roleId]
        res.send 'OK'
      else
        next('No body')