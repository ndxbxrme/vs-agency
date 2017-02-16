'use strict'

angular.module 'vsAgency'
.directive 'progressionPopup', (progressionPopup) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-popup/progression-popup.html'
  replace: true
  link: (scope, elem) ->
    scope.getTitle = progressionPopup.getTitle