'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'platform',
    url: '/'
    templateUrl: 'routes/platform/platform.html'
    controller: 'PlatformCtrl'
    data:
      title: 'Vitalspace Conveyancing - Choose Platform'
      hideMenu: true
    resolve:
      user: (Auth) ->
        Auth.getPromise()