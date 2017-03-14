'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'case',
    url: '/case/:roleId'
    templateUrl: 'routes/case/case.html'
    controller: 'CaseCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise(['agency', 'admin', 'superadmin'])