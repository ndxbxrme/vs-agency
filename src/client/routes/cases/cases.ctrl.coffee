'use strict'

angular.module 'vsAgency'
.controller 'CasesCtrl', ($scope, dezrez) ->
  dezrez.refresh()
  $scope.getProperties = dezrez.getProperties
  $scope.page = 1
    