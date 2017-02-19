'use strict'

angular.module 'vsAgency'
.controller 'SetupCtrl', ($scope, $http) ->
  $scope.addUser = ->
    $http.post '/api/get-invite-code', $scope.newUser
    .then (response) ->
      $scope.inviteUrl = 'http://localhost:3000/invite/' + response.data
    , (err) ->
      false