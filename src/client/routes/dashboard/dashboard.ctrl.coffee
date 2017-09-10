'use strict'

angular.module 'vs-agency'
.controller 'DashboardCtrl', ($scope, $filter, env) ->
  $scope.propsOpts = 
    where:
      delisted: false
  $scope.properties = $scope.list 'properties', $scope.propsOpts, (properties) ->
    for property in properties.items
      completeBeforeDelisted = false
      if property.progressions and property.progressions.length
        progression = property.progressions[0]
        milestone = progression.milestones[progression.milestones.length-1]
        completeBeforeDelisted = (not milestone[0].completed && property.delisted) || not property.delisted
      property.completeBeforeDelisted = completeBeforeDelisted
      property.displayAddress = "#{property.offer.Property.Address.Number} #{property.offer.Property.Address.Street }, #{property.offer.Property.Address.Locality }, #{property.offer.Property.Address.Town}, #{property.offer.Property.Address.Postcode}"
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
        if property and not property.delisted and property.milestoneIndex and angular.isDefined(property.milestoneIndex[di.progression])
          if minIndex <= property.milestoneIndex[di.progression] <= maxIndex
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
        if property and property.progressions and property.completeBeforeDelisted
          for progression in property.progressions
            if progression._id is di.progression
              for branch in progression.milestones
                for milestone in branch
                  if milestone._id is di.minms
                    if month.start <= milestone.estCompletedTime <= month.end
                      value = 0
                      if di.status is 'Due'
                        if not milestone.completed
                          value += property.role.Commission
                      if di.status is 'Completed'
                        if milestone.completed
                          value += property.role.Commission
                      if di.status is 'Started'
                        if milestone.started and not milestone.completed
                          value += property.role.Commission
                      if di.sumtype is 'Income'
                        count += value
                      else
                        if value
                          count++
                      if value and list
                        output.push property
                      break
              break
    if list
      output
    else if di.sumtype is 'Income'
      $filter('currency')(count, '£', 2)
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