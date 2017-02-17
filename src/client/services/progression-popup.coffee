'use strict'

angular.module 'vsAgency'
.factory 'progressionPopup', ($timeout, dezrez, auth) ->
  elem = null
  data = null
  side = null
  hidden = true
  getOffset = (elm) ->
    offset =
      left: 0
      top: 0
    while elm.tagName isnt 'BODY'
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
      if offset.left + (popupWidth + 30) > window.innerWidth
        offset.left = window.innerWidth - (popupWidth + 60)
      if offset.left < 0
        offset.left = 0
      $('.progression-popup').css offset
      pointerLeft = elemLeft - offset.left + 15
      pointerDisplay = 'block'
      if pointerLeft + 20 > popupWidth
        pointerDisplay = 'none'
      $('.progression-popup .pointer').css
        left: pointerLeft
        display: pointerDisplay
  window.addEventListener 'resize', moveToElem
  show: (_elem, _data, _side) ->
    elem = _elem
    data = _data
    side = _side
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
    dezrez.updatePropertyCase auth.getUser(), true
  getProgressing: ->
    if data
      data.progressing
  setProgressing: ->
    if data
      data.progressing = true
      data.startTime = new Date().valueOf()
      hidden = true
      dezrez.updatePropertyCase auth.getUser(), true
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
  addNote: (note) ->
    if data and note
      console.log 'adding note'
      data.notes.push
        date: new Date()
        text: note
        item: data.title
        side: side
        user: auth.getUser()
      dezrez.updatePropertyCase auth.getUser()
  getNotes: ->
    if data
      data.notes