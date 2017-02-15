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
  refresh: ->
    fetchProperties()