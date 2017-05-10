'use strict'

angular.module 'vs-agency'
.controller 'YesNoCancelCtrl', ($scope, data, ndxModalInstance) ->
  $scope.data = data
  $scope.cancel = ->
    ndxModalInstance.dismiss()
  $scope.yes = ->
    ndxModalInstance.close()
  $scope.no = ->
    ndxModalInstance.close()