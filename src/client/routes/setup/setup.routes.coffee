'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'setup',
    url: '/setup'
    templateUrl: 'routes/setup/setup.html'
    controller: 'SetupCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise(['admin', 'superadmin'])