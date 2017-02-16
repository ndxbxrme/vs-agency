'use strict'

angular.module 'vsAgency'
.directive 'progressionSeller', (progression) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-seller/progression-seller.html'
  replace: true
  link: (scope, elem) ->
    resize = ->
      progression.resize elem
    window.addEventListener 'resize', resize
    resize()
    scope.$on '$destroy', ->
      console.log 'destroy'
      window.removeEventListener 'resize', resize