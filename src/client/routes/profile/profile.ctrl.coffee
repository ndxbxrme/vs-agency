'use strict'

angular.module 'vs-agency'
.controller 'ProfileCtrl', ($scope, auth) ->
  $scope.profile = $scope.single 'users', auth.getUser()._id