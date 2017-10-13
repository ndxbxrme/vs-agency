'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'cleanup',
    url: '/cleanup'
    templateUrl: 'routes/cleanup/cleanup.html'
    controller: 'CleanupCtrl'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['admin', 'superadmin'])