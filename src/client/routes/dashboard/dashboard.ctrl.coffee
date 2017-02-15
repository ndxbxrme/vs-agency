'use strict'

angular.module 'vsAgency'
.controller 'DashboardCtrl', ($scope, auth, dezrez) ->
  $scope.auth = auth
  $scope.getProperties = dezrez.getProperties
  $scope.loading = dezrez.loading
  
  $scope.getSalutation = ->
    hours = new Date().getHours()
    if hours < 12
      return 'Good Morning'
    else if hours < 17
      return 'Good Afternoon'
    'Good Evening'