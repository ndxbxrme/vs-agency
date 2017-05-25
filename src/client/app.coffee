'use strict'

angular.module 'vs-agency', [
  'ndx'
  'ui.router'
  'date-swiper'
  'multi-check'
  'ui.gravatar'
  'ngFileUpload'
]
.config (gravatarServiceProvider) ->
  gravatarServiceProvider.defaults =
    size: 16
    "default": 'mm'
    rating: 'pg'
.run ($rootScope, $state, progressionPopup, $http, ndxModal, env) ->
  $http.defaults.headers.common.Authorization = "Bearer #{env.PROPERTY_TOKEN}"
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
  root.modal = (args) ->
    size = args.size or 'large'
    controller = args.controller or 'YesNoCancelCtrl'
    backdrop = args.backdrop or 'static'
    modalInstance = ndxModal.open
      templateUrl: "modals/#{args.template}/#{args.template}.html"
      windowClass: size
      controller: controller
      backdrop: backdrop
      resolve:
        data: ->
          args.data
    modalInstance.result
    
.config ($locationProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'
  $locationProvider.html5Mode true
  console.log '%c', 'font-size:3rem; background:#f15b25 url(https://conveyancing.vitalspace.co.uk/public/img/VitalSpaceLogo-2016.svg);background-size:cover;background-repeat:no-repeat;padding-left:18rem;border:1rem solid #f15b25;border-radius:1rem'
try
  angular.module 'ndx'
catch e
  angular.module 'ndx', [] #ndx module stub