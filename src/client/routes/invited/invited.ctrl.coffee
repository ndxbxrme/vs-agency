'use strict'

angular.module 'vs-agency'
.controller 'InvitedCtrl', ($scope, $state, $http) ->
  code = window.location.search.replace(/^\?/, '')
  $scope.acceptInvite = ->
    $http.post '/invite/accept', 
      code: decodeURIComponent code
      user: $scope.newUser
    .then (response) ->
      if response.data is 'OK'
        $state.go 'dashboard'
    , (err) ->
      false