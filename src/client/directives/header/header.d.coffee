'use strict'

angular.module 'vs-agency'
.directive 'header', ->
  restrict: 'EA'
  templateUrl: 'directives/header/header.html'
  replace: true
  link: (scope, elem, attrs) ->
    scope.toggle = ->
      if not scope.mobileMenuOut
        scope.mobileMenuOut = true
      else
        scope.mobileMenuOut = false