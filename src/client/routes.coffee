'use strict'

angular.module 'vsAgency'
.config ($stateProvider, $locationProvider, $urlRouterProvider) ->
  $stateProvider
  .state 'dashboard',
    url: '/'
    templateUrl: 'routes/dashboard/dashboard.html'
    controller: 'DashboardCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise false
  .state 'cases',
    url: '/cases'
    templateUrl: 'routes/cases/cases.html'
    controller: 'CasesCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise ['agency', 'admin', 'superadmin']
  .state 'case',
    url: '/:roleId/case'
    templateUrl: 'routes/cases/case.html'
    controller: 'CaseCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise ['agency', 'admin', 'superadmin']
  .state 'setup',
    url: '/setup'
    templateUrl: 'routes/setup/setup.html'
    controller: 'SetupCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise ['superadmin', 'admin']
  .state 'invited',
    url: '/invited'
    templateUrl: 'routes/invited/invited.html'
    controller: 'InvitedCtrl'
  $urlRouterProvider.otherwise '/'
  $locationProvider.html5Mode true