'use strict'

angular.module 'vsAgency'
.directive 'progressionBuyer', (progression) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-buyer/progression-buyer.html'
  replace: true
  scope: {}
  link: (scope, elem) ->
    scope.getProgression = ->
      property = scope.$parent.getProperty()
      if property and property.case
        property.case.progressionBuyer
    scope.getSide = ->
      'Buyer'
    resize = ->
      progression.resize elem
    window.addEventListener 'resize', resize
    resize()
    scope.$on '$destroy', ->
      window.removeEventListener 'resize', resize