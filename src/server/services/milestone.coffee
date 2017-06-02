'use strict'
superagent = require 'superagent'

module.exports = (ndx) ->
  fetchContacts = (action, property) ->
    contacts = []
    for contact in action.to
      if contact.indexOf(/^all/) isnt -1
        if contact is 'negotiator'
          negotiator = property.case.offer.Negotiators[0]
          contacts.push 
            name: negotiator.ContactName
            role: negotiator.JobTitle
            email: negotiator.PrimaryEmail.Value
            telephone: negotiator.PrimaryTelephone.Value
        if contact is 'allagency'
          ndx.database.select 'users', null, (res) ->
            if res and res.length
              for user in res
                if user.roles.agency
                  contacts.push
                    name: user.displayName or user.local.email
                    role: 'Agency'
                    email: user.email or user.local.email
                    telephone: user.telephone
        if contact is 'alladmin'
          ndx.database.select 'users', null, (res) ->
            if res and res.length
              for user in res
                if user.roles.admin or user.roles.superadmin
                  contacts.push
                    name: user.displayName or user.local.email
                    role: 'Admin'
                    email: user.email or user.local.email
                    telephone: user.telephone
      else
        contacts.push property.case[contact]
    contacts
  processActions = (actionOn, actions, roleId, property) ->
    if actions and actions.length
      if not property
        #grab property and case details
        superagent.get "#{process.env.PROPERTY_URL}/property/#{roleId}"
        .set 'Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN
        .send()
        .end (err, res) ->
          if not err
            property = res.body
            ndx.property.fetch roleId, (mycase) ->
              property.case = mycase
              processActions actionOn, actions, roleId, property
          else
            throw err
      else
        for action in actions
          if action.on is actionOn
            switch action.type
              when 'Trigger'
                for progression in property.case.progressions
                  for branch in progression.milestones
                    for milestone in branch
                      if milestone._id is action.milestone
                        if action.triggerAction is 'complete'
                          if not milestone.completed
                            isStarted = milestone.startTime
                            milestone.completed = true
                            milestone.progressing = false
                            milestone.startTime = new Date().valueOf()
                            milestone.completedTime = new Date().valueOf()
                            ndx.database.update 'properties', property.case,
                              _id: property.case._id
                            if not isStarted
                              processActions 'Start', milestone.actions, roleId, property
                            processActions 'Complete', milestone.actions, roleId, property
                        else
                          if not milestone.startTime
                            milestone.progressing = true
                            milestone.startTime = new Date().valueOf()
                            ndx.database.update 'properties', property.case,
                              _id: property.case._id
                            processActions 'Start', milestone.actions, roleId, property
              when 'Email'
                contacts = fetchContacts action, property
                ndx.database.select 'emailtemplates',
                  _id: action.template
                , (res) ->
                  if res and res.length
                    for contact in contacts
                      if contact.email and res[0].subject and res[0].body and res[0].from
                        ndx.email.send
                          to: contact.email
                          subject: res[0].subject
                          body: res[0].body
                          from: res[0].from
                          contact: contact
                          property: property
                      else
                        console.log 'bad email template'
                        console.log res[0]
                        console.log  contact
              when 'Sms'
                contacts = fetchContacts action, property
                ndx.database.select 'smstemplates',
                  _id: action.template
                , (res) ->
                  if res and res.length
                    for contact in contacts
                      ndx.zensend.send
                        originator: 'VitalSpace'
                        numbers: [contact.telephone]
                        body: res[0].body
                      ,
                        contact: contact
                        property: property
  ndx.milestone =
    processActions: processActions
    