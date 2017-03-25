'use strict'

angular.module 'vs-agency'
.controller 'SetupCtrl', ($scope, $http, progressionPopup) ->
  $scope.editor = true
  $scope.newUser =
    role: 'agency'
  $scope.progressions = $scope.list 'progressions', null, (progressions) ->
    progressionPopup.setProgressions progressions.items
  $scope.users = $scope.list 'users'
  $scope.emailTemplates = $scope.list 'emailtemplates'
  $scope.smsTemplates = $scope.list 'smstemplates'
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
          _id: $scope.generateId 8
          actions: []
        }]
      ]