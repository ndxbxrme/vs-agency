'use strict'

angular.module 'vs-agency'
.controller 'CasesCtrl', ($scope) ->
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
    route: 'https://myproperty.vitalspace.co.uk/api/search'
  , $scope.propsOpts
  , (properties) ->
    console.log 'called back'
    for property in properties.items
      property.displayAddress = "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}"
      property.$case = $scope.single 'properties', property.RoleId, (item) ->
        item.$parent.search = "#{item.$parent.displayAddress}||#{item.item.vendor}||#{item.item.purchaser}"
        if item.item.progressions and item.item.progressions.length
          for branch in item.item.progressions[0].milestones
            for milestone in branch
              if milestone.completed or milestone.progressing
                item.$parent.milestone = milestone
          if item.$parent.milestone
            item.$parent.milestoneStatus = if item.$parent.milestone.completed then 'completed' else 'progressing'
            item.$parent.cssMilestone = 
              completed: item.$parent.milestone.completed
              progressing: item.$parent.milestone.progressing
        else
          item.$parent.milestoneStatus = ''
      property.$case.$parent = property