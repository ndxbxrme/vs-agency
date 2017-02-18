'use strict'

angular.module 'vsAgency', [
  'ui.router'
  'ui.gravatar'
  'ui.bootstrap'
  'date-swiper'
]
.config (gravatarServiceProvider) ->
  gravatarServiceProvider.defaults =
    size: 16
    "default": 'mm'
    rating: 'pg'
.run ($rootScope, auth) ->
  $rootScope.$on '$stateChangeSuccess', ->
    $('html, body').animate
      scrollTop: 0
    , 200
  auth.getPromise false
  .then ->
    true
  , ->
    false