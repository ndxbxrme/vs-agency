'use strict'

angular.module 'vsAgency'
.controller 'CaseCtrl', ($scope, dezrez, $stateParams) ->
  dezrez.refresh()
  $scope.getProperty = ->
    dezrez.getProperty $stateParams.roleId