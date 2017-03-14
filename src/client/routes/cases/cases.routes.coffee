'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'cases',
    url: '/cases'
    templateUrl: 'routes/cases/cases.html'
    controller: 'CasesCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise(['agency', 'admin', 'superadmin'])