'use strict'

angular.module 'vs-agency'
.controller 'AgreedCtrl', ($scope, $filter, $timeout, $http) ->
  $scope.startDate = 
    'offer.DateTime': new Date(new Date().getFullYear(), 0, 1)
  $scope.endDate =
    'offer.DateTime': new Date()
  $scope.months = []
  testDate = $scope.startDate['offer.DateTime']
  while testDate < $scope.endDate['offer.DateTime']
    month =
      date: testDate
      month: $filter('date')(testDate, 'MMMM')
      properties: []
      target:
        type: 'salesAgreed'
        value: 0
        date: testDate
      search: ''
    $scope.months.push month
    testDate = new Date(testDate.getFullYear(), testDate.getMonth() + 1, testDate.getDate())
  $scope.targets = $scope.list 'targets',
    where:
      type: 'salesAgreed'
  , (targets) ->
    if targets and targets.items and targets.items.length
      for target in targets.items
        for month in $scope.months
          if new Date(target.date).toLocaleString() is month.date.toLocaleString()
            month.target = target
            break
  $scope.properties = $scope.list 'properties',
    where:
      $gte: $scope.startDate
      $lte: $scope.endDate
    sort: 'offer.DateTime'
    sortDir: 'ASC'
  , (properties) ->
    for month in $scope.months
      month.properties = []
      month.commission = 0
    for property in properties.items
      i = $scope.months.length
      while i-- > 0
        month = $scope.months[i]
        if new Date(property.offer.DateTime) > month.date
          completeBeforeDelisted = false
          if property.progressions and property.progressions.length
            progression = property.progressions[0]
            milestone = progression.milestones[progression.milestones.length-1]
            completeBeforeDelisted = (not milestone[0].completed && property.delisted) || not property.delisted
          property.override = property.override or {}
          if not property.override.deleted
            month.commission += +property.override.commission or property.role.Commission
            month.properties.push
              _id: property._id
              address: property.override.address or ("#{property.offer.Property.Address.Number} #{property.offer.Property.Address.Street}, #{property.offer.Property.Address.Locality}")
              commission: property.override.commission or property.role.Commission
              date: property.override.date or property.offer.DateTime
              roleId: property.roleId
              delisted: property.delisted
              completeBeforeDelisted: completeBeforeDelisted
          break
    properties
  $scope.open = (selectedMonth) ->
    open = selectedMonth.open
    for month in $scope.months
      month.open = false
    selectedMonth.open = not open
  $scope.edit = (property) ->
    if not property.$override
      property.$override =
        address: property.address
        commission: property.commission
        date: property.date
    $timeout ->
      property.$editing = true
  $scope.delete = (property) ->
    $http.post "/api/properties/#{property._id}",
      override:
        deleted: true
  $scope.save = (property) ->
    $http.post "/api/properties/#{property._id}",
      override: property.$override
  $scope.cancel = (property) ->
    property.$editing = false
  $scope.saveTarget = (month) ->
    $http.post "/api/targets/#{month.target._id or ''}", month.target
    month.editing = false