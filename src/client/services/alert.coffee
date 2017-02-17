'use strict'

angular.module 'vsAgency'
.factory 'alert', ->
  log: (msg) ->
    humane.log msg