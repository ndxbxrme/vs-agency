'use strict'

angular.module 'vs-agency'
.factory 'progressionPopup', ($timeout, Property, auth) ->
  elem = null
  progressions = []
  data = null
  hidden = true
  scope = null
  reset = ->
    if scope
      scope.action = null
      scope.editingAction = false
  getOffset = (elm) ->
    offset =
      left: 0
      top: 0
    while elm and elm.tagName isnt 'BODY'
      offset.left += elm.offsetLeft
      offset.top += elm.offsetTop
      elm = elm.offsetParent
    offset
  moveToElem = ->
    if elem
      offset = getOffset(elem)
      elemLeft = offset.left
      offset.top += elem.clientHeight
      popupWidth = $('.progression-popup').width()
      if offset.left + (popupWidth + 20) > window.innerWidth
        offset.left = window.innerWidth - (popupWidth + 10)
      offset.left -= 20
      if offset.left < 2
        offset.left = 2
      if window.innerWidth < 410
        offset.left = 2
      $('.progression-popup').css offset
      pointerLeft = elemLeft - offset.left + 10
      pointerDisplay = 'block'
      if pointerLeft + 40 > popupWidth
        pointerDisplay = 'none'
      $('.progression-popup .pointer').css
        left: pointerLeft
        display: pointerDisplay
  window.addEventListener 'resize', moveToElem
  show: (_elem, _data) ->
    elem = _elem
    data = _data
    ###
    if data.title is 'Start' and not data.completed
      data.completed = true
      data.startTime = new Date().valueOf()
      data.completedTime = new Date().valueOf()
      dezrez.updatePropertyCase auth.getUser(), true
    else
    ###
    reset()
    moveToElem()
    hidden = false
  hide: ->
    hidden = true
  getHidden: ->
    hidden
  getTitle: ->
    if data
      data.title
  getCompleted: ->
    if data
      data.completed
  setCompleted: ->
    data.completed = true
    data.progressing = false
    data.completedTime = new Date().valueOf()
    hidden = true
    console.log Property.get()
    Property.get().$case.save()
  getCompletedTime: ->
    if data
      data.completedTime
  getProgressing: ->
    if data
      data.progressing
  setProgressing: ->
    if data
      data.progressing = true
      data.startTime = new Date().valueOf()
      hidden = true
      Property.get().$case.save()
  getDate: ->
    if data
      data.date
  setDate: (date) ->
    if data
      data.date = date
  getStartDate: ->
    if data
      if data.startTime
        return new Date(data.startTime)
      else
        return new Date()
  getEstDays: ->
    if data
      data.estDays
  addNote: (note) ->
    if data and note
      console.log 'adding note'
      data.notes.push
        date: new Date()
        text: note
        item: data.title
        side: data.side
        user: auth.getUser()
      Property.get().$case.save()
  getNotes: ->
    if data
      data.notes
  getData: ->
    data
  setProgressions: (_progressions) ->
    progressions = _progressions
  getProgressions: ->
    progressions
  setScope: (_scope) ->
    scope = _scope
  reset: reset