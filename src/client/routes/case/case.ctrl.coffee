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
        if $scope.note.date
          updateProgressionNotes = (milestones, note) ->
            for branch in milestones
              for milestone in branch
                if milestone.notes and milestone.notes.length
                  for mynote in milestone.notes
                    if mynote.date is note.date and mynote.item is note.item and mynote.side is note.side
                      mynote.text = note.text
                      mynote.updatedAt = new Date()
                      mynote.updatedBy = auth.getUser()
          if property.$case.item.notes
            for mynote in property.$case.item.notes
              if mynote.date is $scope.note.date and mynote.item is $scope.note.item and mynote.side is $scope.note.side
                mynote.text = $scope.note.text
                mynote.updatedAt = new Date()
                mynote.updatedBy = auth.getUser()
          for progression in property.$case.item.progressions
            updateProgressionNotes progression.milestones, $scope.note
        else
          property.$case.item.notes.push
            date: new Date()
            text: $scope.note.text
            item: 'Case Note'
            side: ''
            user: auth.getUser()
        property.$case.save()
        $scope.note = null
  $scope.editNote = (note) ->
    $scope.note = JSON.parse JSON.stringify note
    $('.add-note')[0].scrollIntoView true
  $scope.deleteNote = (note) ->
    property = $scope.property.item
    deleteProgressionNotes = (milestones, note) ->
      for branch in milestones
        for milestone in branch
          if milestone.notes and milestone.notes.length
            for mynote in milestone.notes
              if mynote.date is note.date and mynote.item is note.item and mynote.side is note.side
                return milestone.notes.remove mynote
    if property.$case.item.notes
      for mynote in property.$case.item.notes
        if mynote.date is note.date and mynote.item is note.item and mynote.side is note.side
          property.$case.item.notes.remove mynote
          break
    for progression in property.$case.item.progressions
      deleteProgressionNotes progression.milestones, note
    property.$case.save()
    $scope.note = null
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