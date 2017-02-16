'use strict'

angular.module 'vsAgency'
.factory 'dezrez', ($http) ->
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
    , (err) ->
      false
  fetchProperties = ->
    $http.post 'https://myproperty.vitalspace.co.uk/api/search', RoleStatus:'OfferAccepted'
    .then (response) ->
      properties = response.data.Collection
      for property in properties
        fetchPropertyCase property
    , (err) ->
      properties = []
  updatePropertyCase = ->
    if current
      current.case.roleId = current.RoleId
      $http.post "/api/property/#{current.RoleId}", current.case
      .then (response) ->
        console.log 'done'
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