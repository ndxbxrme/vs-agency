'use strict'

angular.module 'vs-agency'
.controller 'ClientManagementListCtrl', ($scope, env) ->
  $scope.page = 1
  $scope.limit = 15
  $scope.pageChange = ->
    $('html, body').animate
      scrollTop: 0
    , 200
  $scope.properties = $scope.list 'clientmanagement',
    where:
      active: true
  , (properties) ->
    for property in properties.items
      console.log property
      property.displayAddress = "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}, #{property.Address.Postcode}"