'use strict'

angular.module 'vs-agency'
.controller 'AdvanceProgressionCtrl', ($scope, data, $http, ndxModalInstance) ->
  $scope.data = data
  $scope.submit = ->
    $http.post '/api/properties/advance-progression', $scope.data
    .then ->
      ndxModalInstance.dismiss()
    , (e) ->
      ndxModalInstance.dismiss()
  $scope.cancel = ->
    ndxModalInstance.dismiss()