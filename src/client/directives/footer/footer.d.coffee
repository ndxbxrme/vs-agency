'use strict'

angular.module 'vs-agency'
.directive 'footer', ->
  restrict: 'EA'
  templateUrl: 'directives/footer/footer.html'
  replace: true
  link: (scope, elem, attrs) ->