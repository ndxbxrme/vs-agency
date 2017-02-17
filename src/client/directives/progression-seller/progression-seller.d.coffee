'use strict'

angular.module 'vsAgency'
.directive 'progressionSeller', (progression) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-seller/progression-seller.html'
  replace: true
  scope: {}
  link: (scope, elem) ->
    scope.getProgression = ->
      scope.property = scope.$parent.getProperty()
      if scope.property and scope.property.case
        scope.property.case.progressionSeller
    index = 0
    scope.getIndex = ->
      index++
    scope.getSide = ->
      'Seller'
    resize = ->
      progression.resize elem
    window.addEventListener 'resize', resize
    resize()
    scope.$on '$destroy', ->
      window.removeEventListener 'resize', resize