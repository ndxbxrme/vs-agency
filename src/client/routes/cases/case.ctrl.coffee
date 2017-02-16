'use strict'

angular.module 'vsAgency'
.controller 'CaseCtrl', ($scope, dezrez, $stateParams, progressionPopup) ->
  dezrez.refresh()
  $scope.getProperty = ->
    dezrez.getProperty $stateParams.roleId
  $scope.config =
    prefix: 'swiper'
    modifier: 1.5
    show: false
  $scope.date = 
    date: 'today'
  $scope.addNote = ->
    console.log 'add note'
    if $scope.note
      console.log 'got note'
      property = $scope.getProperty()
      if property and property.case
        console.log 'got property'
        property.case.notes.push
          date: new Date()
          text: $scope.note
          item: 'Case Note'
          side: ''
        dezrez.updatePropertyCase()
  $scope.getNotes = ->
    property = $scope.getProperty()
    if property and property.case
      notes = []
      fetchProgressionNotes = (elem) ->
        for item of elem
          if elem[item].notes and elem[item].notes.length
            for note in elem[item].notes
              notes.push note
      fetchProgressionNotes property.case.progressionBuyer
      fetchProgressionNotes property.case.progressionSeller
      if property.case.notes and property.case.notes.length
        for note in property.case.notes
          notes.push note
      return notes
  $scope.$on '$destroy', ->
    progressionPopup.hide()