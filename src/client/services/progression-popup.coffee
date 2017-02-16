'use strict'

angular.module 'vsAgency'
.factory 'progressionPopup', ->
  elem = null
  title = null
  getOffset = (elm) ->
    offset =
      left: 0
      top: 0
    while elm.tagName isnt 'BODY'
      offset.left += elm.offsetLeft
      offset.top += elm.offsetTop
      elm = elm.offsetParent
    offset
  show: (_elem, _title) ->
    elem = _elem
    title = _title
    offset = getOffset(elem)
    elemLeft = offset.left
    offset.top += elem.clientHeight
    if offset.left + 400 > window.innerWidth
      offset.left = window.innerWidth - 440
    $('.progression-popup').css offset
    $('.progression-popup .pointer').css
      left: elemLeft - offset.left + 15
  getTitle: ->
    title