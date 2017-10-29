'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'case',
    url: '/case/:caseId'
    templateUrl: 'routes/case/case.html'
    controller: 'CaseCtrl'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])