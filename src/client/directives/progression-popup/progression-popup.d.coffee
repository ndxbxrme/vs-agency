'use strict'

angular.module 'vs-agency'
.directive 'progressionPopup', ($rootScope, progressionPopup) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-popup/progression-popup.html'
  replace: true
  link: (scope, elem) ->
    addingNote = false
    scope.icons = [
      'cathead'
      'house'
      'epc'
      'instruction'
      'draft'
      'fandf'
      'survey'
      'offer'
      'raised'
      'satisfied'
      'applied'
      'complete'
      'report'
      'exchange'
      'invoice'
      'completion'
    ]
    scope.getData = progressionPopup.getData
    scope.getTitle = progressionPopup.getTitle
    scope.setCompleted = progressionPopup.setCompleted
    scope.getCompleted = progressionPopup.getCompleted
    scope.getCompletedTime = progressionPopup.getCompletedTime
    scope.getProgressing = progressionPopup.getProgressing
    scope.getHidden = progressionPopup.getHidden
    scope.getNotes = progressionPopup.getNotes
    scope.hide = progressionPopup.hide
    scope.getDate = progressionPopup.getDate
    scope.setDate = ->
      $rootScope.$emit 'swiper:show', progressionPopup.getDate()
    scope.setProgressing = ->
      progressionPopup.setProgressing()
    getDateDiff = (startDate, endDate) ->
      end = moment(endDate)
      start = moment(startDate).startOf('day')
      nodays = end.diff start, 'days'
      nodays + if nodays is 1 then ' day' else ' days'
    scope.getEstDays = ->
      date = progressionPopup.getDate()
      start = progressionPopup.getStartDate()
      estDays = progressionPopup.getEstDays()
      if date
        getDateDiff start, date
      else
        date = moment().startOf('day').add(estDays, 'day')._d
        progressionPopup.setDate date
        getDateDiff start, date
      
    scope.isStart = ->
      title = progressionPopup.getTitle()
      title is 'Start'
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