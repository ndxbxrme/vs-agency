'use strict'

angular.module 'vs-agency'
.controller 'DashboardCtrl', ($scope, $filter, env) ->
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
      property.$case = $scope.single 'properties', property.RoleId
  $scope.dashboard = $scope.list 'dashboard',
    sort: 'i'
  $scope.progressions = $scope.list 'progressions'
  $scope.count = (di, list) ->
    output = []
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
            if list
              output.push property
            count++
    if list
      output
    else
      count
  $scope.total = (items) ->
    total = 0
    if items
      for item in items
        total += $scope.count item
    total
  $scope.income = (di, month, list) ->
    count = 0
    output = []
    if $scope.properties and $scope.properties.items
      for property in $scope.properties.items
        if property.$case and property.$case.item and property.$case.item.progressions
          for progression in property.$case.item.progressions
            if progression._id is di.progression
              for branch in progression.milestones
                for milestone in branch
                  if milestone._id is di.minms
                    if month.start <= milestone.estCompletedTime <= month.end
                      if list
                        output.push property
                      if di.sumtype is 'Income'
                        if property.Fees and property.Fees.length and property.Fees[0].FeeValueType
                          if property.Fees[0].FeeValueType.SystemName is 'Percentage'
                            count += Math.floor(property.$case.item.offer.Value * (property.Fees[0].DefaultValue / 100))
                          else if property.Fees[0].FeeValueType.SystemName is 'Absolute'
                            count += property.Fees[0].DefaultValue
                      else
                        count++
                      break
              break
    if list
      output
    else if di.sumtype is 'Income'
      $filter('currency')(count, '£', 0)
    else
      count
  $scope.showInfo = (type, di, month) ->
    list = null
    if type is 'count'
      list = $scope.count di, true
    else
      list = $scope.income di, month, true
    if list.length
      $scope.modal
        template: 'dashboard-income'
        controller: 'DashboardIncomeCtrl'
        data:
          di: di
          month: month
          list: list
      .then ->
        true
      , ->
        false
  monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  $scope.months = []
  now = new Date()
  bmonth = new Date now.getFullYear(), now.getMonth() - 1
  $scope.allmonths =
    start: bmonth.valueOf()
    end: 0
  i = 0
  while i++ < 5
    month = {
      name: monthNames[bmonth.getMonth()]
      start: bmonth.valueOf()
      end: 0
    }
    bmonth.setMonth(bmonth.getMonth() + 1)
    month.end = bmonth.valueOf() - 1
    $scope.months.push month
  $scope.allmonths.end = bmonth.valueOf()