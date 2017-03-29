'use strict'

angular.module 'vs-agency'
.controller 'SetupCtrl', ($scope, $http, progressionPopup) ->
  $scope.editor = true
  $scope.newUser =
    role: 'agency'
  $scope.progressions = $scope.list 'progressions', 
    sort: 'i'
  , (progressions) ->
    progressionPopup.setProgressions progressions.items
  $scope.users = $scope.list 'users'
  $scope.emailTemplates = $scope.list 'emailtemplates'
  $scope.smsTemplates = $scope.list 'smstemplates'
  $scope.dashboard = $scope.list 'dashboard'
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
  $scope.resetProgressions = ->
    $http.get '/api/properties/reset-progressions'
    .then (response) ->
      console.log response
  saveDashboard = ->
    for di, i in $scope.dashboard.items
      di.i = i
      $scope.dashboard.save di
  $scope.moveDIUp = (di) ->
    $scope.dashboard.items.moveUp di
    console.log $scope.dashboard.items
    saveDashboard()
  $scope.moveDIDown = (di) ->
    $scope.dashboard.items.moveDown di
    saveDashboard()
  $scope.removeDI = (di) ->
    $scope.dashboard.delete di
    $scope.dashboard.items.remove di
    saveDashboard()
    
    