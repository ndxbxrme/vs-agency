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
        superagent.get "https://myproperty.vitalspace.co.uk/api/property/#{roleId}"
        .send()
        .end (err, res) ->
          if not err
            property = res
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
                          milestone.completed = true
                          milestone.progressing = false
                          milestone.completedTime = new Date().valueOf()
                        else
                          milestone.progressing = true
                          milestone.startTime = new Date().valueOf()
                        ndx.database.update 'properties', property.case
                        return processActions (if action.triggerAction is 'complete' then 'Complete' else 'Start'), milestone.actions, roleId, property
              when 'Email'
                contacts = fetchContacts action, property
                ndx.database.select 'emailtemplates',
                  _id: action.template
                , (res) ->
                  if res and res.length
                    for contact in contacts
                      ndx.gmail.send
                        template: res[0]._id + '.jade'
                        to: contact.email
                        subject: res[0].subject
                        contact: contact
                        property: property
              when 'Sms'
                contacts = fetchContacts action, property
                ndx.database.select 'smsTemplates',
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
    