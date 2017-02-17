'use strict'

angular.module 'vsAgency'
.factory 'dezrez', ($http, alert) ->
  loading = false
  properties = []
  current = null
  fetchPropertyCase = (property) ->
    $http.get "/api/property/#{property.RoleId}"
    .then (response) ->
      if response.data
        property.case = response.data
        if response.data.lastUpdated
          property.LastUpdated = response.data.lastUpdated
        property.case.progressionBuyer = property.case.progressionBuyer or {}
        property.case.progressionSeller = property.case.progressionSeller or {}
        property.case.notes = property.case.notes or []
        fetchMilestone = (side) ->
          property['milestone' + side] =
            index: -1
          for key of property.case['progression' + side]
            if key is 'start'
              property['startDate' + side] = property.case['progression' + side][key].startTime
            if property.case['progression' + side][key].index > property['milestone' + side].index
              if property.case['progression' + side][key].completed or property.case['progression' + side][key].progressing
                property['milestone' + side] = property.case['progression' + side][key]
          if property['milestone' + side].index > -1
            property['milestone' + side + 'Status'] = if property['milestone' + side].completed then 'completed' else 'progressing'
            property['cssMilestone' + side] =
              completed: property['milestone' + side].completed
              progressing: property['milestone' + side].progressing
            cssName = _.str.camelize(_.str.slugify(property['milestone' + side].title))
            property['cssMilestone' + side][cssName] = true
          else
            property['milestone' + side + 'Status'] = ''
        fetchMilestone 'Buyer'
        fetchMilestone 'Seller'
    , (err) ->
      false
  fetchProperties = ->
    $http.post 'https://myproperty.vitalspace.co.uk/api/search', 
      RoleStatus:'OfferAccepted'
      RoleType: 'Selling'
      IncludeStc: true
    .then (response) ->
      properties = response.data.Collection
      for property in properties
        fetchPropertyCase property
    , (err) ->
      properties = []
  updatePropertyCase = (user, setLastUpdated) ->
    if current and current.case
      console.log 'got current and case'
      if setLastUpdated
        current.case.lastUpdated = new Date()
        current.case.lastUpdatedBy = user
      current.case.roleId = current.RoleId
      $http.post "/api/property/#{current.RoleId}", current.case
      .then (response) ->
        alert.log 'Case updated'
      , (err) ->
        console.log 'nope'
  
  properties = []
  getProperties: ->
    properties
  getProperty: (roleId) ->
    if current and current.roleId is +roleId
      return current
    for property in properties
      if property.RoleId is +roleId
        current = property
        return property
  updatePropertyCase: updatePropertyCase
  refresh: ->
    fetchProperties()