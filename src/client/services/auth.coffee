'use strict'

angular.module 'vsAgency'
.factory 'auth', ($http, $q, $timeout, $location, dezrez) ->
  user = null
  loading = false
  getUserPromise = (needsDezrez) ->
    loading = true
    defer = $q.defer()
    if user
      defer.resolve user
      loading = false
    else
      $http.post '/api/refresh-login'
      .then (data) ->
        loading = false
        if data and data.data isnt 'error'
          user = data.data
          defer.resolve user
        else 
          user = null
          defer.reject {}
      , ->
        loading = false
        user = null
        defer.reject {}
    defer.promise
  getPromise: (needsDezrez) ->
    defer = $q.defer()
    getUserPromise needsDezrez
    .then ->
      defer.resolve user
    , ->
      defer.reject {}
      $location.path '/'
    defer.promise
  getDezrezPromise: (email) ->
    defer = $q.defer()
    getDezrezPromise defer, true, email
    defer.promise
  getUser: ->
    user
  getDezrezUser: ->
    if user and user.dezrez then user else null
  getPotentialUsers: ->
    potentialUsers
  clearPotentialUsers: ->
    potentialUsers = []
  loading: ->
    loading