'use strict'

angular.module 'vs-agency'
.directive 'header', ($state) ->
  restrict: 'EA'
  templateUrl: 'directives/header/header.html'
  replace: true
  link: (scope, elem, attrs) ->
    scope.hideMenu = ->
      $state.current.data?.hideMenu
    scope.toggle = ($event) ->
      if not scope.mobileMenuOut
        scope.mobileMenuOut = true
      else
        scope.mobileMenuOut = false
      $event.stopPropagation()