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
    propName = _.str.camelize(_.str.slugify(scope.title))
    elem[0].className += ' ' + propName
    scope.getClass = ->
      progression = scope.$parent.getProgression()
      if progression and progression[propName]
        return {
          completed: progression[propName].completed
          progressing: progression[propName].progressing
        }
    index = scope.$parent.getIndex()
    scope.itemClick = ->
      progression = scope.$parent.getProgression()
      if progression
        if not progression[propName]
          progression[propName] =
            title: scope.cleanTitle
            progressing: false
            date: ''
            notes: []
            index: index
      progressionPopup.show elem[0], progression[propName], scope.$parent.getSide()
      #$rootScope.$emit 'swiper:show' 
    