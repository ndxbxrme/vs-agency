'use strict'

angular.module 'vsAgency'
.controller 'DashboardCtrl', ($scope, auth, dezrez) ->
  $scope.getUser = auth.getUser