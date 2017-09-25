'use strict'

angular.module 'vs-agency'
.controller 'InvitedCtrl', ($scope, $state, $http) ->
  code = window.location.search.replace(/^\?/, '')
  codeBits = unescape(code).split(/  /)
  if codeBits.length is 2
    code = codeBits[0]
    try
      $scope.newUser = JSON.parse atob(codeBits[1])
    catch e
      false
  $scope.acceptInvite = ->
    if $scope.repeatPassword is $scope.newUser.local.password
      $http.post '/invite/accept', 
        code: decodeURIComponent code
        user: $scope.newUser
      .then (response) ->
        if response.data is 'OK'
          $state.go 'dashboard'
      , (err) ->
        false
    else
      $scope.error = 'Passwords must match'