'use strict'

checkedIds = []
module.exports = (ndx) ->
  ndx.database.on 'ready', ->
    ndx.database.select 'properties', null, (properties) ->
      for property in properties
        if property.override and property.override.deleted and not property.delisted
          ndx.database.delete 'properties',
            _id: property._id