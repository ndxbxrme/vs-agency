'use strict'

angular.module 'vs-agency'
.controller 'CleanupCtrl', ($scope, $filter, $timeout, $http) ->
  $scope.properties = $scope.list 'properties', null, (properties) ->
    i = properties.items.length
    while i-- > 0
      property = properties.items[i]
      property.displayAddress = property.override?.address or ("#{property.offer.Property.Address.Number} #{property.offer.Property.Address.Street}, #{property.offer.Property.Address.Locality}")
      property.exchangeDate = property.progressions[0]?.milestones[10]?[0]?.userCompletedTime or property.progressions[0]?.milestones[10]?[0]?.estCompletedTime
      if property.milestoneIndex and property.milestoneIndex['58e4ec46a32a15f543d72098']
        if property.milestoneIndex['58e4ec46a32a15f543d72098'] > 9
          properties.items.splice i, 1
          continue
      if property.exchangeDate > new Date().valueOf()
        properties.items.splice i, 1
        console.log property
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
    true
  $scope.delete = (property) ->
    true
  $scope.fallenThrough = (property) ->
    true