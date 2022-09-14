'use strict'

angular.module 'vs-agency'
.controller 'ClientManagementDetailsCtrl', ($scope, $stateParams, $state, $timeout, $window, Auth, progressionPopup, Property, Upload, env, alert) ->
  $scope.property = $scope.single 'clientmanagement', $stateParams.id, (res) ->
    property = res.item
    property.displayAddress = "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}, #{property.Address.Postcode}"
    console.log property
  $scope.date = 
    date: 'today'
  $scope.addNote = ->
    console.log 'add note', $scope
    if $scope.note
      property = $scope.property.item
      if property
        if $scope.note.date
          if property.notes
            for mynote in property.notes
              if mynote.date is $scope.note.date and mynote.item is $scope.note.item and mynote.side is $scope.note.side
                mynote.text = $scope.note.text
                mynote.updatedAt = new Date()
                mynote.updatedBy = Auth.getUser()
        else
          property.notes = [] if not property.notes
          property.notes.push
            date: new Date()
            text: $scope.note.text
            item: 'Case Note'
            side: ''
            user: Auth.getUser()
        $scope.property.save()
        alert.log 'Note added'
        $scope.note = null
  $scope.editNote = (note) ->
    $scope.note = JSON.parse JSON.stringify note
    $('.add-note')[0].scrollIntoView true
  $scope.deleteNote = (note) ->
    property = $scope.property.item
    if property.notes
      for mynote in property.notes
        if mynote.date is note.date and mynote.item is note.item and mynote.side is note.side
          property.notes.remove mynote
          break
    $scope.property.save()
    alert.log 'Note deleted'
    $scope.note = null
  $scope.getNotes = ->
    $scope.property?.item?.notes
