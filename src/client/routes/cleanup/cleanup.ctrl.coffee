'use strict'

angular.module 'vs-agency'
.controller 'CleanupCtrl', ($scope, $filter, $timeout, $http) ->
  $scope.loading = true
  $scope.progressions = $scope.list 'progressions',
    isdefault: true
  , (progressions) ->
    console.log progressions
    $scope.properties = $scope.properties or $scope.list 'properties', null, (properties) ->
      i = properties.items.length
      while i-- > 0
        property = properties.items[i]
        property.displayAddress = property.override?.address or ("#{property.offer.Property.Address.Number} #{property.offer.Property.Address.Street}, #{property.offer.Property.Address.Locality}")
        property.exchangeDate = property.progressions[0]?.milestones[10]?[0]?.userCompletedTime or property.progressions[0]?.milestones[10]?[0]?.estCompletedTime
        if property.milestoneIndex and property.milestoneIndex[progressions.items[0]._id]
          if property.milestoneIndex[progressions.items[0]._id] > 9
            properties.items.splice i, 1
            continue
        if property.exchangeDate > new Date().valueOf() or property.override?.deleted
          properties.items.splice i, 1
      $scope.loading = false
  $scope.sort = 'offer.Property.Address.Street'
  $scope.doSort = (field) ->
    if not $scope.sort
      $scope.sort = ''
    if $scope.sort.indexOf(field) is -1
      $scope.sort = field
      $scope.sortDir = 'ASC'
    else
      if $scope.sort.indexOf('-') is 0
        $scope.sort = field
        $scope.sortDir = 'ASC'
      else
        $scope.sort = "-#{field}"
        $scope.sortDir = 'DESC'
  $scope.class = (field) ->
    "has-sort": true
    sorting: -1 < $scope.sort.indexOf(field) < 2
    desc: $scope.sortDir is 'DESC'
  $scope.complete = (property) ->
    property.processing = true
    if not property.progressions or property.progressions.length is 0
      property.progressions = []
      for progression in $scope.progressions.items
        property.progressions.push JSON.parse JSON.stringify progression
    property.milestoneIndex = property.milestoneIndex or {}
    if property.progressions and property.progressions.length
      for progression in property.progressions
        console.log progression
        progression.milestones[progression.milestones.length-1][0].completed = true
        progression.milestones[progression.milestones.length-1][0].completedDate = property.exchangeDate
        property.milestoneIndex[progression._id] = progression.milestones.length - 1
      property.milestone = Object.assign {}, property.progressions[0].milestones[property.progressions[0].milestones.length-1][0]
    $http.post "/api/properties/#{property._id}",
      progressions: property.progressions
      milestone: property.milestone
      milestoneIndex: property.milestoneIndex
    true
  $scope.delete = (property) ->
    property.processing = true
    $http.post "/api/properties/#{property._id}",
      override:
        deleted: true
        reason: 'deleted'
  $scope.fallenThrough = (property) ->
    property.processing = true
    $http.post "/api/properties/#{property._id}",
      override:
        deleted: true
        reason: 'fallenThrough'
    true