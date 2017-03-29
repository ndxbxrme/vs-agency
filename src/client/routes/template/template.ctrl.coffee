'use strict'

angular.module 'vs-agency'
.controller 'TemplateCtrl', ($scope, $stateParams, $state, $http) ->
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
      $state.go 'setup'
  $scope.cancel = ->
    $state.go 'setup'
    
  $scope.defaultData = {}
  fetchDefaultProp = ->
    $http.post 'https://myproperty.vitalspace.co.uk/api/search',
      RoleStatus: 'OfferAccepted'
      RoleType: 'Selling'
      IncludeStc: true
      PageSize: 1
    .then (response) ->
      if response.data and response.data.Collection and response.data.Collection.length
        $scope.defaultData.property = response.data.Collection[0]
        $http.get "/api/properties/#{$scope.defaultData.property.RoleId}"
        .then (response) ->
          if response.data
            $scope.defaultData.property.case = response.data
            $scope.defaultData.contact = response.data.vendorsContact
  fetchDefaultProp()