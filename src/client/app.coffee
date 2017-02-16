'use strict'

angular.module 'vsAgency', [
  'ui.router'
  'ui.gravatar'
  'date-swiper'
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