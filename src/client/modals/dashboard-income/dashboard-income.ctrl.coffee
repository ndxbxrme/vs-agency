'use strict'

angular.module 'vs-agency'
.controller 'DashboardIncomeCtrl', ($scope, $state, data, ndxModalInstance) ->
  $scope.limit = 10
  $scope.page = 1
  $scope.data = data
  $scope.cancel = ->
    ndxModalInstance.dismiss()
  $scope.yes = ->
    ndxModalInstance.close()
  $scope.no = ->
    ndxModalInstance.close()
  $scope.Math = Math
  $scope.go = (property) ->
    ndxModalInstance.close()
    $state.go 'case',
      roleId:property.RoleId