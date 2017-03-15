'use strict'

module.exports = (ndx) ->
  ndx.property =
    fetch: (roleId, cb) ->
      property = ndx.database.exec 'SELECT * FROM properties WHERE roleId=?', [+roleId]
      if property and property.length
        if property[0].progressions and property[0].progressions.length
          for branch in property[0].progressions[0].milestones
            for milestone in branch
              if milestone.completed or milestone.progressing
                property[0].milestone = milestone
          if property[0].milestone
            property[0].milestoneStatus = if property[0].milestone.completed then 'completed' else 'progressing'
            property[0].cssMilestone = 
              completed: property[0].milestone.completed
              progressing: property[0].milestone.progressing
        cb? property[0]
      else
        property =
          roleId: +roleId
        ndx.dezrez.get 'role/{id}', null, id:roleId, (err, body) ->
          if not err
            ndx.dezrez.get 'role/{id}', null, id:body.PurchasingRoleId, (err, body) ->
              if not err
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
                property.progressions = []
                property.mileston
                property.milestoneStatus = ''
                property.notes = []
                property.chainBuyer = []
                property.chainSeller = []
                ndx.database.insert 'properties', property
                cb? property
              else
                throw err
          else
            throw err
  