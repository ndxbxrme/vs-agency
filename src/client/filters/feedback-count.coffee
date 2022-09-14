'use strict'

angular.module 'vs-agency'
.filter 'getFeedbackCount', ->
  (property) ->
    return if not property
    count = 0
    for viewing in property.viewings
      count += (viewing.Feedback or []).length
    count