'use strict'

angular.module 'vs-agency'
.controller 'TemplateCtrl', ($scope, $stateParams, $window) ->
  $scope.type = $stateParams.type
  if $stateParams.type is 'email'
    $scope.lang = 'jade'
    $scope.template = $scope.single 'emailtemplates', $stateParams.id
  else
    $scope.lang = 'text'
    $scope.template = $scope.single 'smstemplates', $stateParams.id
  $scope.save = ->
    if $scope.myForm.$valid
      $scope.template.save()
      $window.history.back()