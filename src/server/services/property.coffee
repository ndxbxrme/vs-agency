'use strict'
superagent = require 'superagent'
async = require 'async'

module.exports = (ndx) ->
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
  checkNew = ->
    opts = 
      RoleStatus: 'OfferAccepted'
      RoleType: 'Selling'
      IncludeStc: true
    superagent.post "#{process.env.PROPERTY_URL}/search"
    .set 'Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN
    .send opts
    .end (err, res) ->
      if not err and res.body.Collection
        async.eachSeries res.body.Collection, (property, callback) ->
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
              #check for progression updates
              propClone = JSON.stringify mycase
              calculateMilestones mycase
              if propClone isnt JSON.stringify mycase
                ndx.database.update 'properties',
                  modifiedAt: new Date().valueOf()
                ,
                  _id: mycase._id
              callback()
  setInterval checkNew, 10 * 60 * 1000
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
                  if property.role and JSON.stringify(property.role) is JSON.stringify(body)
                    return propcb? property
                  else
                    property.role = body
                    property.offer = body.AcceptedOffer
                    property.purchaser = body.AcceptedOffer.ApplicantGroup.Name
                    property.purchasersContact =
                      role: ''
                      name: body.AcceptedOffer.ApplicantGroup.PrimaryMember.ContactName
                      email: body.AcceptedOffer.ApplicantGroup.PrimaryMember.PrimaryEmail?.Value
                      telephone: body.AcceptedOffer.ApplicantGroup.PrimaryMember.PrimaryTelephone?.Value
                    for contact in body.Contacts
                      property["#{contact.ProgressionRoleType.SystemName.toLowerCase()}sSolicitor"] =
                        role: contact.GroupName
                        name: contact.CaseHandler.ContactName
                        email: contact.CaseHandler.PrimaryEmail?.Value
                        telephone: contact.CaseHandler.PrimaryTelephone?.Value
                    property.vendor = body.AcceptedOffer.VendorGroup.Name
                    property.vendorsContact =
                      role: ''
                      name: body.AcceptedOffer.VendorGroup.PrimaryMember.ContactName
                      email: body.AcceptedOffer.VendorGroup.PrimaryMember.PrimaryEmail?.Value
                      telephone: body.AcceptedOffer.VendorGroup.PrimaryMember.PrimaryTelephone?.Value
                    propcb? property
                else
                  throw err
            else
              throw err
        
        if property and property.length
          cb? property[0]
          if property[0].modifiedAt + (60 * 60 * 1000) < new Date().valueOf()
            fetchPropertyRole property[0].roleId, property[0], (property) ->
              ndx.database.update 'properties', property,
                _id: property._id
        else
          property =
            roleId: roleId.toString()
          fetchPropertyRole roleId, property, (property) ->
            getDefaultProgressions property
            property.milestone = ''
            property.milestoneStatus = ''
            property.milestoneIndex = null
            property.notes = []
            property.chainBuyer = []
            property.chainSeller = []
            ndx.database.insert 'properties', property
            cb? property
