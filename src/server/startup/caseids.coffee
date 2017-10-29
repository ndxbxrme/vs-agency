'use strict'
superagent = require 'superagent'
async = require 'async'

module.exports = (ndx) ->
  ndx.database.on 'ready', ->
    ndx.database.select 'properties', null, (properties) ->
      async.eachSeries properties, (property, callback) ->
        superagent.get "#{process.env.PROPERTY_URL}/property/#{property.roleId}"
        .set 'Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN
        .send()
        .end (err, res) ->
          if not err
            caseId = property.roleId
            if res.body.DateInstructed
              console.log property.roleId
              caseId = property.roleId + '' + res.body.DateInstructed?.replace(/[-TZ:]/gi, '')
            ndx.database.update 'properties',
              caseId: caseId
            ,
              _id: property._id
            , ->
              console.log 'updated', property._id
          callback()