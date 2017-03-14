'use strict'

angular.module 'vs-agency'
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
      console.log scope.disabled
      if scope.disabled isnt 'true'
        progressionPopup.show elem[0], scope.milestone
      #$rootScope.$emit 'swiper:show' 
    