'use strict'

angular.module 'vs-agency'
.controller 'CaseCtrl', ($scope, $stateParams, $timeout, auth, progressionPopup, Property) ->
  $scope.notesLimit = 10
  $scope.notesPage = 1
  $scope.property = $scope.single
    route: 'https://myproperty.vitalspace.co.uk/api/property'
  , $stateParams.roleId
  , (res) ->
    property = res.item
    property.displayAddress = "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}"
    property.$case = $scope.single 'properties', property.RoleId, (item) ->
      item.parent.search = "#{item.parent.displayAddress}||#{item.vendor}||#{item.purchaser}"
      checkProgressions()
    property.$case.parent = property
    Property.set property
  $scope.progressions = $scope.list 'progressions', null, checkProgressions
  checkProgressions = ->
    if $scope.property and $scope.property.$case and $scope.progressions.items and $scope.progressions.items.length
      if $scope.property.$case.item.progressions.length < 1
        $scope.property.$case.item.progressions = JSON.parse JSON.stringify $scope.progressions.items
        $scope.property.$case.save()
  $scope.config =
    prefix: 'swiper'
    modifier: 1.5
    show: false
  $scope.date = 
    date: 'today'
  $scope.addNote = ->
    if $scope.note
      property = $scope.property.item
      if property and property.$case and property.$case.item
        property.$case.item.notes.push
          date: new Date()
          text: $scope.note
          item: 'Case Note'
          side: ''
          user: auth.getUser()
        property.$case.save()
        $scope.note = ''
  $scope.getNotes = ->
    property = $scope.property.item
    if property and property.$case and property.$case.item
      notes = []
      fetchProgressionNotes = (milestones) ->
        for branch in milestones
          for milestone in branch
            if milestone.notes and milestone.notes.length
              for note in milestone.notes
                notes.push note
      for progression in property.$case.item.progressions
        fetchProgressionNotes progression.milestones
      if property.$case.item.notes and property.$case.item.notes.length
        for note in property.$case.item.notes
          notes.push note
      return notes
  $scope.addProgression = (progression) ->
    property = $scope.property.item
    if property and property.$case and property.$case.item
      if not property.$case.item.progressions
        property.$case.item.progressions = []
      property.$case.item.progressions.push JSON.parse(JSON.stringify(progression)) 
      property.$case.save()
  $scope.hideDropdown = (dropdown) ->
    $timeout ->
      $scope[dropdown] = false
    , 200
  $scope.$on '$destroy', ->
    progressionPopup.hide()