'use strict'

angular.module 'vsAgency'
.controller 'SetupCtrl', ($scope, $http, progressions) ->
  progressions.refresh()
  $scope.editor = true
  $scope.newUser =
    role: 'agency'
  $scope.getProgressions = progressions.getProgressions
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
    progressions.saveProgression
      name: 'New progression'
      side: 'Buyer'
      milestones: [
        [{
          title: 'Start'
        }]
      ]
    progressions.refresh()