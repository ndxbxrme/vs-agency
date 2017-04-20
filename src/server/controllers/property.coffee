'use strict'
superagent = require 'superagent'
progress = require 'progress'

module.exports = (ndx) ->
  ndx.app.get '/api/properties/reset-progressions', ndx.authenticate(['admin','superadmin']), (req, res, next) ->
    ndx.database.select 'properties', null, (properties) ->
      if properties and properties.length
        for property in properties
          ndx.database.update 'properties',
            progressions: []
            milestone: ''
            milestoneIndex: ''
            milestoneStatus: ''
            cssMilestone: ''            
          ,
            _id: property._id
        ndx.property.checkNew()
      res.end 'OK'
  ndx.app.get '/api/properties/:roleId', ndx.authenticate(), (req, res, next) ->
    ndx.property.fetch req.params.roleId, (property) ->
      res.json property
  #startup
  ndx.database.on 'ready', ->
    if not ndx.database.count 'properties'
      console.log 'building database'
      superagent.post process.env.PROPERTY_URL
      .set 'Content-Type', 'application/json'
      .set 'Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN
      .send
        RoleStatus: 'OfferAccepted'
        RoleType: 'Selling'
        IncludeStc: true
      .end (err, response) ->
        console.log 'building property database'
        if not err and response and response.body
          bar = new progress '  downloading [:bar] :percent :etas',
            complete: '='
            incomplete: ' '
            width: 20
            total: response.body.Collection.length
          fetchProp = (index) ->
            bar.tick 1
            if index < response.body.Collection.length
              ndx.property.fetch response.body.Collection[index].RoleId, ->
                fetchProp ++index
            else
              console.log '\ndatabase build complete'
          fetchProp 0
      