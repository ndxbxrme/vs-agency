'use strict'

angular.module 'vs-agency'
.directive 'mobileMenu', ->
  restrict: 'AE'
  templateUrl: 'directives/mobile-menu/mobile-menu.html'
  replace: true
  link: (scope) ->