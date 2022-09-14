'use strict'

angular.module 'vs-agency'
.filter 'numMailouts', ->
  (property) ->
    return if not property
    (property.events.Collection or []).reduce (res, event) ->
      res++ if event.EventType.Name is 'Mailout'
      res
    , 0