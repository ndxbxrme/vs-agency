'use strict'

module.exports = (ndx) ->
  ndx.database.on 'ready', ->
    ndx.database.select 'properties', null, (props) ->
      for prop in props
        prop.startDate = prop.progressions?[0]?.milestones[0][0].startTime
        ndx.database.update 'properties',
          startDate: prop.progressions?[0]?.milestones[0][0].startTime
        ,
          _id: prop._id
      console.log 'updated start dates'