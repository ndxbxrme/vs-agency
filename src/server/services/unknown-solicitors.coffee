module.exports = (ndx) ->
  ndx.database.on 'ready', ->
    nextSendTime = null
    sendUnknownSolicitorEmails = ->
      ndx.database.select 'properties', null, (properties) ->
        solicitors = []
        myproperties = []
        reduce = (name) ->
          (name or 'Unknown').toLowerCase().replace(/solicitor(s*)/g, '').replace(/law|llp/g,'').replace(/ll/g, 'l').replace(/ [a-z] /, '').replace(' & ', '').replace(' and ', '').replace(/\s+/g, '')
        getSolicitor = (name, sol) ->
          for solicitor in solicitors
            if reduce(solicitor.name) is reduce(name)
              return solicitor
          solicitor =
            id: solicitors.length
            name: name or 'Unknown'
          solicitors.push solicitor
          solicitor
        for property in properties
          ps = getSolicitor property.purchasersSolicitor?.role
          vs = getSolicitor property.vendorsSolicitor?.role
          if ps.name is 'Unknown' or vs.name is 'Unknown'
            if not myproperties.filter((item) -> item.id is property.roleId).length
              myproperties.push
                address: "#{property.offer?.Property?.Address.Number} #{property.offer?.Property?.Address.Street }, #{property.offer?.Property?.Address.Locality }, #{property.offer?.Property?.Address.Town}, #{property.offer?.Property?.Address.Postcode}"
                id: property.roleId
                purchasingSolicitor: ps.name is 'Unknown'
                vendingSolicitor: vs.name is 'Unknown'
        if myproperties.length
          if ndx.email
            ndx.database.select 'emailtemplates',
              name: 'Unknown Solicitors'
            , (template) ->
              if template and templates.length
                templates[0].properties = myproperties
                templates[0].user = user
                templates[0].to = user.local?.email
                ndx.email.send templates[0]
    resetNextSendTime = ->
      nextSendTime = new Date(new Date(new Date().toDateString()).setHours(8))
      nextSendTime = new Date(nextSendTime.setDate(nextSendTime.getDate() + 1))
    resetNextSendTime()
    setInterval ->
      if new Date() > nextSendTime
        sendUnknownSolicitorEmails()
        resetNextSendTime()
    , 10000