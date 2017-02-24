'use strict'

angular.module 'vsAgency'
.directive 'milestone', ($rootScope, progressionPopup) ->
  restrict: 'AE'
  templateUrl: 'directives/milestone/milestone.html'
  replace: true
  scope:
    milestone: '=data'
    disabled: '@'
  link: (scope, elem, attrs) ->
    scope.getClass = ->
      completed: scope.milestone.completed
      progressing: scope.milestone.progressing
    scope.itemClick = ->
      if scope.disabled is 'false'
        progressionPopup.show elem[0], scope.milestone
      #$rootScope.$emit 'swiper:show' 
    