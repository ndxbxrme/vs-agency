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
.run ($rootScope, $state, auth) ->
  $rootScope.$on '$stateChangeStart', ->
    if $state.current.name
      $('body').removeClass "#{$state.current.name}-page"
  $rootScope.$on '$stateChangeSuccess', ->
    if $state.current.name
      $('body').addClass "#{$state.current.name}-page"
    $('html, body').animate
      scrollTop: 0
    , 200
  #some useful array functions
  Array.prototype.remove = (thing) ->
    @splice @.indexOf(thing), 1
  Array.prototype.moveUp = (thing) ->
    index = @indexOf thing
    if index > 0
      @splice index, 1
      @splice index - 1, null, thing
  Array.prototype.moveDown = (thing) ->
    index = @indexOf thing
    if index > -1 and index < this.length - 1
      @splice index, 1
      @splice index + 1, null, thing