'use strict'

angular.module 'vs-agency'
.controller 'CaseCtrl', ($scope, $stateParams, $timeout, auth, progressionPopup, Property) ->
  $scope.property = $scope.single
    route: 'https://myproperty.vitalspace.co.uk/api/property'
  , $stateParams.roleId
  , (res) ->
    property = res.item
    property.displayAddress = "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}"
    property.$case = $scope.single 'properties', property.RoleId, (item) ->
      item.parent.search = "#{item.parent.displayAddress}||#{item.vendor}||#{item.purchaser}"
    property.$case.parent = property
    Property.set property
  $scope.progressions = $scope.list 'progressions'
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
      property = $scope.property.item
      if property and property.$case and property.$case.item
        console.log 'got property'
        property.$case.item.notes.push
          date: new Date()
          text: $scope.note
          item: 'Case Note'
          side: ''
          user: auth.getUser()
        property.$case.save()
  $scope.getNotes = ->
    property = $scope.property.item
    if property and property.$case and property.$case.item
      notes = []
      fetchProgressionNotes = (elem) ->
        for item of elem
          if elem[item].notes and elem[item].notes.length
            for note in elem[item].notes
              notes.push note
      fetchProgressionNotes property.$case.item.progressionBuyer
      fetchProgressionNotes property.$case.item.progressionSeller
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