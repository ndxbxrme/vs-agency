'use strict'

angular.module 'vsAgency'
.controller 'CasesCtrl', ($scope, dezrez) ->
  dezrez.refresh()
  $scope.getProperties = dezrez.getProperties
  $scope.page = 1
  $scope.limit = 15
  $scope.pageChange = ->
    $('html, body').animate
      scrollTop: 0
    , 200