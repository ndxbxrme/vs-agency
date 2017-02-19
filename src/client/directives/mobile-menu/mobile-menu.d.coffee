'use strict'

angular.module 'vsAgency'
.directive 'mobileMenu', ($state, auth) ->
  restrict: 'AE'
  templateUrl: 'directives/mobile-menu/mobile-menu.html'
  replace: true
  link: (scope) ->
    scope.checkRoles = auth.checkRoles
    scope.isSelected = (route) ->
      if $state and $state.current
        if Object.prototype.toString.call(route) is '[object Array]'
          return route.indexOf($state.current.name) isnt -1
        else
          return route is $state.current.name
      false