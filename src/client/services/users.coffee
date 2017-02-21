'use strict'

angular.module 'vsAgency'
.factory 'users', ($http) ->
  users = []
  fetchUsers = ->
    $http.get '/api/users'
    .then (response) ->
      users = response.data
    , (err) ->
      false
  refresh: ->
    fetchUsers()
  getUsers: ->
    users
  getUser: (id) ->
    for user in users
      if user._id is id
        return user
  