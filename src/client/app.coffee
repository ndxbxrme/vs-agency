'use strict'

angular.module 'vs-agency', [
  'ndx'
  'ui.router'
  'date-swiper'
  'multi-check'
]
.run ($rootScope, $state, progressionPopup) ->
  $rootScope.state = (route) ->
    if $state and $state.current
      if Object.prototype.toString.call(route) is '[object Array]'
        return route.indexOf($state.current.name) isnt -1
      else
        return route is $state.current.name
    false
  $rootScope.$on '$stateChangeStart', ->
    if $state.current.name
      progressionPopup.hide()
      $('body').removeClass "#{$state.current.name}-page"
  $rootScope.$on '$stateChangeSuccess', ->
    if $state.current.name
      $('body').addClass "#{$state.current.name}-page"
      
  root = Object.getPrototypeOf $rootScope
  root.generateId = (len) ->
    letters = "abcdefghijklmnopqrstuvwxyz0123456789"
    output = ''
    i = 0
    while i++ < len
      output += letters[Math.floor(Math.random() * letters.length)]
    output
  root.hidePopup = (ev) ->
    progressionPopup.hide()
    
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
.config ($locationProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'
  $locationProvider.html5Mode true
try
  angular.module 'ndx'
catch e
  angular.module 'ndx', [] #ndx module stub