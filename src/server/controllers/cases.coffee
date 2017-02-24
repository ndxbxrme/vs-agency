'use strict'

module.exports = (ndx) ->
  if process.env.REZI_ID and process.env.REZI_SECRET
    pageSize =
      pageSize: 2000
    ndx.app.get '/api/property/:roleId', ndx.authenticate(), (req, res, next) ->
      property = ndx.database.exec 'SELECT * FROM properties WHERE roleId=?', [+req.params.roleId]
      if property and property.length
        res.json property[0]
      else
        property =
          roleId: +req.params.roleId
        ndx.dezrez.get 'role/{id}', null, id:req.params.roleId, (err, body) ->
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
                ndx.database.insert 'properties', property
                res.json property
              else
                return next(err)
          else
            return next(err)
    ndx.app.post '/api/property/:roleId', ndx.authenticate(), (req, res, next) ->
      if req.body
        ndx.database.update 'properties', req.body, 'roleId=?', [req.body.roleId]
        res.send 'OK'
      else
        next('No body')