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
      overdue: if scope.milestone.completed then false else new Date().valueOf > (scope.milestone.userCompletedTime or scope.milestone.estCompletedTime)
    scope.itemClick = ->
      if scope.disabled isnt 'true'
        progressionPopup.show elem[0], scope.milestone
      #$rootScope.$emit 'swiper:show' 
    