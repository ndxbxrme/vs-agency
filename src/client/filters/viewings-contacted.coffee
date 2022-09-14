'use strict'

angular.module 'vs-agency'
.filter 'viewingContacted', ->
  (property) ->
    return if not property
    nocompleted = 0
    for viewing in property.viewings
      if viewing.EventStatus.Name is 'Completed'
        nocompleted++
    nocompleted