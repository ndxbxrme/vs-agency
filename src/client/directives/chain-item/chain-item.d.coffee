'use strict'

angular.module 'vs-agency'
.directive 'chainItem', ->
  restrict: 'EA'
  templateUrl: 'directives/chain-item/chain-item.html'
  replace: true
  link: (scope, elem, attrs) ->
    console.log 'chain-item directive'