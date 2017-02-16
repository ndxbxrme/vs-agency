'use strict'

angular.module 'vsAgency'
.controller 'CaseCtrl', ($scope, dezrez, $stateParams) ->
  dezrez.refresh()
  $scope.getProperty = ->
    dezrez.getProperty $stateParams.roleId
  $scope.config =
    prefix: 'swiper'
    modifier: 1.5
    show: false
  $scope.date = 
    date: 'today'