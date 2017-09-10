'use strict'
superagent = require 'superagent'
diff = require 'deep-diff'
.diff

checkedIds = []
module.exports = (ndx) ->
  ndx.database.on 'ready', ->
    toDelete = []
    opts = 
      RoleStatus: 'OfferAccepted'
      RoleType: 'Selling'
      IncludeStc: true
    superagent.post "#{process.env.PROPERTY_URL}/search"
    .set 'Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN
    .send opts
    .end (err, res) ->
      if not err and res.body.Collection
        ndx.database.select 'properties', 
          null
        , (properties) ->
          if properties and properties.length
            for property, i in properties
              foundRole = false
              for prop in res.body.Collection
                if +property.roleId is +prop.RoleId
                  foundRole = true
                  break
              ndx.database.update 'properties',
                delisted: not foundRole
              ,
                _id: property._id.toString()
              , ->
                if checkedIds.indexOf(property.roleId) is -1
                  checkedIds.push property.roleId
                  ndx.database.select 'properties',
                    where:
                      roleId: property.roleId
                  , (props) ->
                    if props and props.length > 1
                      console.log ''
                      props = props.sort (a, b) ->
                        a.modifiedAt - b.modifiedAt
                      for p, i in props
                        if i isnt props.length - 1
                          ndx.database.delete 'properties', 
                            _id: p._id
                          console.log 'delete'
                        console.log property.roleId, p._id, p.notes.length
                        console.log new Date(p.modifiedAt)
            ndx.property.checkNew()