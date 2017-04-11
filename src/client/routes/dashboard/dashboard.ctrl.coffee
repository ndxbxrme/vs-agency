'use strict'

angular.module 'vs-agency'
.controller 'DashboardCtrl', ($scope, $filter) ->
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
    for property in properties.items
      property.$case = $scope.single 'properties', property.RoleId
  $scope.dashboard = $scope.list 'dashboard',
    sort: 'i'
  $scope.progressions = $scope.list 'progressions'
  $scope.count = (di) ->
    count = 0
    minIndex = 0
    maxIndex = 100
    if $scope.properties and $scope.properties.items and $scope.progressions and $scope.progressions.items
      for progression in $scope.progressions.items
        if progression._id is di.progression
          for branch, b in progression.milestones
            for milestone in branch
              if milestone._id is di.minms
                minIndex = b
              if milestone._id is di.maxms
                maxIndex = b
                break
      for property in $scope.properties.items
        if property.$case and property.$case.item and property.$case.item.milestoneIndex and angular.isDefined(property.$case.item.milestoneIndex[di.progression])
          if minIndex <= property.$case.item.milestoneIndex[di.progression] <= maxIndex
            count++
    count
  $scope.total = (items) ->
    total = 0
    if items
      for item in items
        total += $scope.count item
    total
  $scope.income = (di, month) ->
    count = 0
    if $scope.properties and $scope.properties.items
      for property in $scope.properties.items
        if property.$case and property.$case.item and property.$case.item.progressions
          for progression in property.$case.item.progressions
            if progression._id is di.progression
              for branch in progression.milestones
                for milestone in branch
                  if milestone._id is di.minms
                    if month.start <= milestone.estCompletedTime <= month.end
                      if di.sumtype is 'Income'
                        if property.Fees[0].FeeValueType.SystemName is 'Percentage'
                          count += property.$case.item.offer.Value * (property.Fees[0].DefaultValue / 100)
                        else if property.Fees[0].FeeValueType.SystemName is 'Absolute'
                          count += property.Fees[0].DefaultValue
                      else
                        count++
                      break
              break
    if di.sumtype is 'Income'
      $filter('currency')(count, '£', 0)
    else
      count
  monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  $scope.months = []
  now = new Date()
  bmonth = new Date now.getFullYear(), now.getMonth()
  $scope.allmonths =
    start: bmonth.valueOf()
    end: 0
  i = 0
  while i++ < 3
    month = {
      name: monthNames[bmonth.getMonth()]
      start: bmonth.valueOf()
      end: 0
    }
    bmonth.setMonth(bmonth.getMonth() + 1)
    month.end = bmonth.valueOf() - 1
    $scope.months.push month
  $scope.allmonths.end = bmonth.valueOf()