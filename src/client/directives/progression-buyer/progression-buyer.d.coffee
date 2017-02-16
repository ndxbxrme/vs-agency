'use strict'

angular.module 'vsAgency'
.directive 'progressionBuyer', (progression) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-buyer/progression-buyer.html'
  replace: true
  link: (scope, elem) ->
    resize = ->
      progression.resize elem
    window.addEventListener 'resize', resize
    resize()
    scope.$on '$destroy', ->
      console.log 'destroy'
      window.removeEventListener 'resize', resize