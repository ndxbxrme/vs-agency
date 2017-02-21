'use strict'

angular.module 'vsAgency'
.directive 'progression', (progression, dezrez, $http, alert) ->
  restrict: 'AE'
  templateUrl: 'directives/progression/progression.html'
  replace: true
  scope: 
    progression: '=data'
  link: (scope, elem) ->
    scope.getProgression = ->
      scope.progression
    scope.getProperty = ->
      scope.$parent.getProperty()
    index = 0
    scope.getIndex = ->
      index++
    scope.addMilestone = (branch) ->
      if not branch
        branch = []
        scope.progression.milestones.push branch
      branch.push
        title: 'New Milestone'
        notes: []
        todos: []
        estDays: 0
      resize()
    scope.saveProgression = ->
      $http.post '/api/progression', scope.progression
      .then (response) ->
        alert.log 'Progression saved'
      , (err) ->
        false
    scope.remove = ->
      scope.$parent.getProperty().case.progressions.remove scope.progression
      dezrez.updatePropertyCase()
    scope.moveUp = ->
      scope.$parent.getProperty().case.progressions.moveUp scope.progression
      dezrez.updatePropertyCase()
    scope.moveDown = ->
      scope.$parent.getProperty().case.progressions.moveDown scope.progression
      dezrez.updatePropertyCase()
    resize = ->
      progression.resize elem
    resize()
    window.addEventListener 'resize', resize
    scope.$on '$destroy', ->
      window.removeEventListener 'resize', resize