'use strict'

angular.module 'vs-agency'
.controller 'DashboardItemCtrl', ($scope, $stateParams, $window) ->
  $scope.type = $stateParams.type
  $scope.dashboardItem = $scope.single 'dashboard', $stateParams.id
  $scope.progressions = $scope.list 'progressions',
    sort: 'i'
  $scope.getMilestones = ->
    if $scope.progressions and $scope.progressions.items and $scope.dashboardItem and $scope.dashboardItem.item
      for progression in $scope.progressions.items
        if progression._id is $scope.dashboardItem.item.progression
          output = []
          for branch in progression.milestones
            output.push branch[0]
          return output
  $scope.save = ->
    $scope.dashboardItem.item.type = $scope.type
    $scope.dashboardItem.save()
    $window.history.go -1
  $scope.cancel = ->
    $window.history.go -1