'use strict'

angular.module 'vs-agency'
.controller 'SetupCtrl', ($scope, $http) ->
  $scope.editor = true
  $scope.newUser =
    role: 'agency'
  console.log 'heeey'
  $scope.progressions = $scope.list 'progressions'
  $scope.getProperty = ->
    Address:
      Number: 123
      Street: 'My Street'
      Locality: 'My Locality'
      Town: 'My Town'
  $scope.addUser = ->
    $http.post '/api/get-invite-code', $scope.newUser
    .then (response) ->
      $scope.inviteUrl = "#{window.location.protocol}//#{window.location.host}/invite/#{response.data}"
    , (err) ->
      $scope.inviteError = err.data
  $scope.addProgression = ->
    $scope.progressions.save
      name: 'New progression'
      side: 'Buyer'
      milestones: [
        [{
          title: 'Start'
        }]
      ]