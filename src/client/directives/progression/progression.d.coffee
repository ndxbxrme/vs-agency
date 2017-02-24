'use strict'

angular.module 'vsAgency'
.directive 'progression', (progression, progressionPopup, dezrez, $http, alert) ->
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
      scope.resize()
    scope.saveProgression = ->
      progressionPopup.hide()
      $http.post '/api/progression', scope.progression
      .then (response) ->
        alert.log 'Progression saved'
        scope.editing = false
        scope.resize()
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
    scope.resize = ->
      progression.resize elem
    scope.resize()
    window.addEventListener 'resize', scope.resize
    scope.$on '$destroy', ->
      window.removeEventListener 'resize', scope.resize