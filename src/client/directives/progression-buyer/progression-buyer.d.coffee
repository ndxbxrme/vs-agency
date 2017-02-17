'use strict'

angular.module 'vsAgency'
.directive 'progressionBuyer', (progression) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-buyer/progression-buyer.html'
  replace: true
  scope: {}
  link: (scope, elem) ->
    scope.getProgression = ->
      scope.property = scope.$parent.getProperty()
      if scope.property and scope.property.case
        scope.property.case.progressionBuyer
    index = 0
    scope.getIndex = ->
      index++
    scope.getSide = ->
      'Buyer'
    resize = ->
      progression.resize elem
    window.addEventListener 'resize', resize
    resize()
    scope.$on '$destroy', ->
      window.removeEventListener 'resize', resize