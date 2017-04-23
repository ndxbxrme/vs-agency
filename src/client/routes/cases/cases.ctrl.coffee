'use strict'

angular.module 'vs-agency'
.controller 'CasesCtrl', ($scope, env) ->
  $scope.page = 1
  $scope.limit = 15
  $scope.pageChange = ->
    $('html, body').animate
      scrollTop: 0
    , 200
  $scope.propsOpts = 
    where:
      RoleStatus: 'OfferAccepted'
      RoleType: 'Selling'
      IncludeStc: true
    transform:
      items: 'Collection'
      total: 'TotalCount'
  $scope.properties = $scope.list
    route: "#{env.PROPERTY_URL}/search"
  , $scope.propsOpts
  , (properties) ->
    for property in properties.items
      property.displayAddress = "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}"
      property.$case = $scope.single 'properties', property.RoleId, (item) ->
        item.$parent.search = "#{item.$parent.displayAddress}||#{item.item.vendor}||#{item.item.purchaser}"
        item.$parent.milestoneStatus = item.item.milestoneStatus
        if item.item.progressions and item.item.progressions.length
          item.$parent.estCompletedTime = item.item.progressions[0].milestones[item.item.progressions[0].milestones.length-1][0].estCompletedTime
        if item.$parent.estCompletedTime < new Date().valueOf()
          item.$parent.needsDate = true
      property.$case.$parent = property