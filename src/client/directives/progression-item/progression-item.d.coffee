'use strict'

angular.module 'vsAgency'
.directive 'progressionItem', ($rootScope, progressionPopup) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-item/progression-item.html'
  replace: true
  scope:
    title: '@'
  link: (scope, elem, attrs) ->
    scope.cleanTitle = scope.title.replace(/\d+/g, '')
    elem[0].className += ' ' + _.str.slugify(scope.title)
    scope.itemClick = ->
      progressionPopup.show elem[0], scope.cleanTitle
      #$rootScope.$emit 'swiper:show' 
    