'use strict'
superagent = require 'superagent'
asy = require 'async'

module.exports = (ndx) ->
  ndx.database.on 'ready', ->
    ndx.database.select 'properties',
      override:
        deleted: true
    , (props) ->
      for prop in props
        ndx.database.delete 'properties',
          _id: prop._id
        console.log 'deleted', prop._id
  getDefaultProgressions = (property) ->
    property.progressions = []
    ndx.database.select 'progressions',
      isdefault: true
    , (progressions) ->
      for progression in progressions
        ###
        for milestone in progression.milestones[0]
          milestone.progressing = false
          milestone.completed = true
          milestone.startTime = new Date().valueOf()
          milestone.completedTime = new Date().valueOf()
        ###
        property.progressions.push JSON.parse JSON.stringify progression
  calculateMilestones = (property) ->
    if property.progressions and property.progressions.length
      updateEstDays = (progressions) ->
        aday = 24 * 60 * 60 * 1000
        fetchMilestoneById = (id, progressions) ->
          for myprogression in progressions
            for mybranch in myprogression.milestones
              for mymilestone in mybranch
                if mymilestone._id is id
                  return mymilestone
        for progression in progressions
          for branch in progression.milestones
            for milestone in branch
              milestone.estCompletedTime = null
        needsCompleting = true
        i = 0
        while needsCompleting and i++ < 5
          for progression in progressions
            delete progression.needsCompleting
            progStart = progression.milestones[0][0].completedTime
            b = 1
            while b++ < progression.milestones.length
              branch = progression.milestones[b-1]
              for milestone in branch
                milestone.overdue = false
                milestone.afterTitle = ''
                if milestone.estCompletedTime
                  continue
                if milestone.completed and milestone.completedTime
                  milestone.estCompletedTime = milestone.completedTime
                  continue
                if milestone.userCompletedTime
                  try
                    milestone.estCompletedTime = new Date(milestone.userCompletedTime).valueOf()
                    continue
                if not milestone.estAfter
                  prev = progression.milestones[b-2][0]
                  milestone.estCompletedTime = (prev.completedTime or prev.estCompletedTime) + (milestone.estDays * aday)
                  continue
                testMilestone = fetchMilestoneById milestone.estAfter, progressions
                if testMilestone
                  if milestone.estType is 'complete'
                    if testMilestone.completedTime or testMilestone.estCompletedTime
                      milestone.estCompletedTime = (testMilestone.completedTime or testMilestone.estCompletedTime) + (milestone.estDays * aday)
                    milestone.afterTitle = " after #{testMilestone.title} completed"
                  else
                    if testMilestone.completedTime or testMilestone.estCompletedTime
                      milestone.estCompletedTime = (testMilestone.completedTime or testMilestone.estCompletedTime) - (testMilestone.estDays * aday) + (milestone.estDays * aday)
                    milestone.afterTitle = " after #{testMilestone.title} started"
                else
                  progression.needsCompleting = true
                  b = progression.milestones.length
                  break
          needsCompleting = false
          for progression in progressions
            if progression.needsCompleting
              needsCompleting = true
        for progression in progressions
          delete progression.needsCompleting 
      updateEstDays property.progressions
      property.milestoneIndex = {}
      gotOverdue = false
      for progression, p in property.progressions
        for branch, b in progression.milestones
          for milestone in branch
            if milestone.userCompletedTime
              milestone.userCompletedTime = new Date(milestone.userCompletedTime).valueOf()
            if new Date().valueOf() > (milestone.userCompletedTime or milestone.estCompletedTime)
              milestone.overdue = true
              if p is 0 and milestone.progressing and not gotOverdue
                property.milestone = milestone
                gotOverdue = true
            if p is 0 and not gotOverdue
              if milestone.completed or milestone.progressing
                property.milestone = milestone
            if milestone.completed #unsure
              property.milestoneIndex[progression._id] = b
      if property.milestone
        property.milestoneStatus = 'progressing'
        if property.milestone.overdue
          property.milestoneStatus = 'overdue'
        if property.milestone.completed
          property.milestoneStatus = 'completed'
        property.cssMilestone = 
          completed: property.milestone.completed
          progressing: property.milestone.progressing
          overdue: property.milestoneStatus is 'overdue'
  fetchClientManagementProperties = ->
    new Promise (resolve) ->
      opts = 
        RoleStatus: 'InstructionToSell'
        RoleType: 'Selling'
        IncludeStc: true
      superagent.post "#{process.env.PROPERTY_URL}/search"
      .set 'Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN
      .send opts
      .end (err, res) ->
        if not err and res.body.Collection
          now = new Date().getTime()
          Promise.all res.body.Collection.map (property) ->
            new Promise (propRes) ->
              Promise.all [
                new Promise (res) -> 
                  ndx.dezrez.get 'role/{id}/viewingsbasic', null, id:property.RoleId, (err, body) -> 
                    property.viewings = body
                    res(body)
                  , ndx.dezrez.get 'property/{id}', null, id:property.PropertyId, (err, body) -> 
                    property.extendedData = body
                    res(body)
                  , ndx.dezrez.get 'role/{id}', null, id:property.RoleId, (err, body) -> 
                    property.role = body
                    res(body)
                  , ndx.dezrez.get 'property/{id}/owners', null, id:property.PropertyId, (err, body) -> 
                    property.vendor = body
                    res(body)
                  , ndx.dezrez.get 'stats/rightmove/{id}', null, id:property.RoleId, (err, body) -> 
                    property.rightmove = body
                    res(body)
                  , ndx.dezrez.get 'role/{id}/offers', null, id:property.RoleId, (err, body) -> 
                    property.offers = body
                    res(body)
                  , ndx.dezrez.get 'role/{id}/events', {pageSize:200}, id:property.RoleId, (err, body) -> 
                    property.events = body
                    res(body)
              ]
              .then ->
                property.active = true
                property.now = now
                new Promise (res) ->
                  ndx.database.select 'clientmanagement',
                    RoleId: property.RoleId
                  , (items) -> res items[0]
                .then (dbprop) ->
                  if dbprop
                    property._id = dbprop._id
                    property.notes = dbprop.notes
                    ndx.database.upsert 'clientmanagement', property
                  else
                    property.notes = []
                    ndx.database.insert 'clientmanagement', property
                  propRes()
          .then ->
            ndx.database.update 'clientmanagement',
              active: false
            ,
              now: $lt: now
            resolve()
        else
          resolve()
  checkCount = 0
  checkNew = ->
    #fetchClientManagementProperties()
    opts = 
      RoleStatus: 'OfferAccepted'
      RoleType: 'Selling'
      IncludeStc: true
    superagent.post "#{process.env.PROPERTY_URL}/search"
    .set 'Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN
    .send opts
    .end (err, res) ->
      console.log 'superagent post returned'
      if not err and res.body.Collection
        asy.eachSeries res.body.Collection, (property, callback) ->
          ndx.property.fetch property.RoleId.toString(), (mycase) ->
            if not mycase.progressions or not mycase.progressions.length
              ndx.property.getDefaultProgressions mycase
              ndx.database.update 'properties', 
                progressions: mycase.progressions
              ,
                _id:mycase._id
              , ->
                callback()
            else
              #if deleted or completed then check for new offer id
              #check for progression updates
              propClone = JSON.stringify mycase
              calculateMilestones mycase
              if propClone isnt JSON.stringify mycase
                mycase.modifiedAt = new Date().valueOf()
                ndx.database.update 'properties', mycase,
                  _id: mycase._id
              callback()
        , ->
          ndx.database.select 'properties',
            delisted: false
          , (properties) ->
            if properties and properties.length
              asy.eachSeries properties, (property, propCallback) ->
                foundRole = false
                for prop in res.body.Collection
                  if +property.roleId is +prop.RoleId
                    foundRole = true
                    break
                if not foundRole
                  ndx.database.update 'properties',
                    delisted: true
                  ,
                    _id: property._id.toString()
                propCallback()
  ndx.database.on 'ready', ->
    #setInterval checkNew, 10 * 60 * 1000
    #checkNew()
  webhookCalls = 0
  ndx.app.post '/webhook', (req, res, next) ->
    console.log 'WEBHOOK CALLED'
    webhookCalls++
    checkNew()
    res.end 'ok'
  ndx.app.post '/status', (req, res, next) ->
    res.json webhookCalls: webhookCalls
  ndx.database.on 'preUpdate', (args, cb) ->
    if args.table is 'properties'
      property = args.obj
      calculateMilestones property
    cb()
  ndx.property =
    getDefaultProgressions: getDefaultProgressions
    checkNew: checkNew
    fetch: (roleId, cb) ->
      ndx.database.select 'properties',
        roleId: roleId.toString()
      , (property) ->
        fetchPropertyRole = (roleId, property, propcb) ->
          ndx.dezrez.get 'role/{id}', null, id:roleId, (err, body) ->
            if not err
              ndx.dezrez.get 'role/{id}', null, id:body.PurchasingRoleId, (err, body) ->
                if not err
                  if body.RoleStatus?.SystemName isnt 'OfferAccepted'
                    property.badProp = true
                    return propcb? property
                  if property.role and JSON.stringify(property.role) is JSON.stringify(body)
                    property.delisted = false
                    return propcb? property
                  else
                    property.delisted = false
                    property.role = body
                    property.offer = body.AcceptedOffer
                    property.purchaser = body.AcceptedOffer.ApplicantGroup.Name
                    property.purchasersContact =
                      role: ''
                      name: body.AcceptedOffer.ApplicantGroup.PrimaryMember?.ContactName
                      email: body.AcceptedOffer.ApplicantGroup.PrimaryMember?.PrimaryEmail?.Value
                      telephone: body.AcceptedOffer.ApplicantGroup.PrimaryMember?.PrimaryTelephone?.Value
                    for contact in body.Contacts
                      property["#{contact.ProgressionRoleType.SystemName.toLowerCase()}sSolicitor"] =
                        role: contact.GroupName
                        name: contact.CaseHandler.ContactName
                        email: contact.CaseHandler.PrimaryEmail?.Value
                        telephone: contact.CaseHandler.PrimaryTelephone?.Value
                    property.vendor = body.AcceptedOffer.VendorGroup.Name
                    property.vendorsContact =
                      role: ''
                      name: body.AcceptedOffer.VendorGroup.PrimaryMember?.ContactName
                      email: body.AcceptedOffer.VendorGroup.PrimaryMember?.PrimaryEmail?.Value
                      telephone: body.AcceptedOffer.VendorGroup.PrimaryMember?.PrimaryTelephone?.Value
                    propcb? property
                else
                  return propcb? null
            else
              return propcb? null
        
        if property and property.length
          offerId = property[0].offer.Id
          cb? property[0]
          if property[0].override?.deleted and property[0].roleId.toString().indexOf('_') is -1
            ndx.database.update 'properties',
              roleId: property[0].roleId + '_' + property[0].offer.Id
            ,
              roleId: property[0].roleId
          else if property[0].modifiedAt + (60 * 60 * 1000) < new Date().valueOf()
            fetchPropertyRole property[0].roleId, property[0], (prop) ->
              if prop
                if prop.offer.Id isnt offerId
                  if property[0].delisted
                    ndx.database.update 'properties',
                      roleId: property[0].roleId + '_' + offerId
                    ,
                      roleId: property[0].roleId
                  else
                    ndx.database.update 'properties',
                      offer: prop.offer
                    ,
                      roleId: property[0].roleId
                else
                  ndx.database.update 'properties', prop,
                    _id: prop._id
        else
          property =
            roleId: roleId.toString()
            startDate: new Date().valueOf()
          fetchPropertyRole roleId, property, (property) ->
            if property and not property.badProp
              getDefaultProgressions property
              property.delisted = false
              property.milestone = ''
              property.milestoneStatus = ''
              property.milestoneIndex = null
              property.notes = []
              property.chainBuyer = []
              property.chainSeller = []
              property.delisted = false
              ndx.database.insert 'properties', property
            cb? property