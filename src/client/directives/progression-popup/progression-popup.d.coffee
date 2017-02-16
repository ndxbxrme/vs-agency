'use strict'

angular.module 'vsAgency'
.directive 'progressionPopup', ($rootScope, progressionPopup) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-popup/progression-popup.html'
  replace: true
  link: (scope, elem) ->
    addingNote = false
    scope.getTitle = progressionPopup.getTitle
    scope.setCompleted = progressionPopup.setCompleted
    scope.getCompleted = progressionPopup.getCompleted
    scope.getProgressing = progressionPopup.getProgressing
    scope.getHidden = progressionPopup.getHidden
    scope.getNotes = progressionPopup.getNotes
    scope.hide = progressionPopup.hide
    scope.getDate = progressionPopup.getDate
    scope.setDate = ->
      $rootScope.$emit 'swiper:show', progressionPopup.getDate()
    scope.setProgressing = ->
      progressionPopup.setProgressing()
    scope.getDateDiff = ->
      end = moment(progressionPopup.getDate())
      start = moment(progressionPopup.getStartDate()).startOf('day')
      nodays = end.diff start, 'days'
      nodays + if nodays is 1 then ' day' else ' days'
    scope.addNote = ->
      addingNote = true
    scope.addingNote = ->
      addingNote
    scope.doAddNote = ->
      progressionPopup.addNote scope.note
      scope.note = ''
      addingNote = false
    scope.cancelAddNote = ->
      scope.note = ''
      addingNote = false
      
    deregister = $rootScope.$on 'set-date', (e, date) ->
      progressionPopup.setDate date
    scope.$on '$destroy', ->
      deregister()