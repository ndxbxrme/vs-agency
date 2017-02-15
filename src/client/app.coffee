'use strict'

angular.module 'vsAgency', [
  'ui.router'
  'ui.gravatar'
]
.config (gravatarServiceProvider) ->
  gravatarServiceProvider.defaults =
    size: 16
    "default": 'mm'
    rating: 'pg'
.run (auth) ->
  auth.getPromise false
  .then ->
    true
  , ->
    false