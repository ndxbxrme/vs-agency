'use strict'

angular.module 'vs-agency'
.directive 'header', ->
  restrict: 'EA'
  templateUrl: 'directives/header/header.html'
  replace: true
  link: (scope, elem, attrs) ->
    toggle = ->
      console.log 'menu out', scope.mobileMenuOut