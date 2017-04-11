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
    property.$case.parent = property
    Property.set property
  $scope.progressions = $scope.list 'progressions',
    sort: 'i'
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
  $scope.addChain = (chain, side) ->
    index = 0
    if side is 'seller'
      index = $scope.property.item.$case.item.chainSeller.length
    chain.push
      note: ''
      reference: ''
      side: side
    $scope.chainEdit = side + index
  $scope.editChain = (side, index) ->
    $scope.chainEdit = side + index
  $scope.saveChain = ->
    $scope.chainEdit = null
    $scope.property.item.$case.save()
  $scope.deleteChainItem = (item, side) ->
    chain = if side is 'buyer' then $scope.property.item.$case.item.chainBuyer else $scope.property.item.$case.item.chainSeller
    chain.remove item
    $scope.saveChain()
  $scope.hideDropdown = (dropdown) ->
    $timeout ->
      $scope[dropdown] = false
    , 200
  $scope.$on '$destroy', ->
    progressionPopup.hide()