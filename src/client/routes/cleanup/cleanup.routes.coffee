'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'cleanup',
    url: '/cleanup'
    templateUrl: 'routes/cleanup/cleanup.html'
    controller: 'CleanupCtrl'
    data:
      title: 'Vitalspace Conveyancing - Cleanup'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['admin', 'superadmin'])