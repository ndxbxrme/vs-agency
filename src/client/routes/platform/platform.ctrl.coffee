'use strict'

angular.module 'vs-agency'
.controller 'PlatformCtrl', ($scope, $state) ->
  hideMenu = $state.current.data.hideMenu