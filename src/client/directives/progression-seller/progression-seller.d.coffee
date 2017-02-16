'use strict'

angular.module 'vsAgency'
.directive 'progressionSeller', (progression) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-seller/progression-seller.html'
  replace: true
  scope: {}
  link: (scope, elem) ->
    scope.getProgression = ->
      property = scope.$parent.getProperty()
      if property and property.case
        property.case.progressionSeller
    scope.getSide = ->
      'Seller'
    resize = ->
      progression.resize elem
    window.addEventListener 'resize', resize
    resize()
    scope.$on '$destroy', ->
      window.removeEventListener 'resize', resize