'use strict'

angular.module 'vsAgency'
.config ($stateProvider, $locationProvider, $urlRouterProvider) ->
  $stateProvider
  .state 'dashboard',
    url: '/'
    templateUrl: 'routes/dashboard/dashboard.html'
    controller: 'DashboardCtrl'
  .state 'cases',
    url: '/cases'
    templateUrl: 'routes/cases/cases.html'
    controller: 'CasesCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise false
  .state 'case',
    url: '/:roleId/case'
    templateUrl: 'routes/cases/case.html'
    controller: 'CaseCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise false
  .state 'setup',
    url: '/setup'
    templateUrl: 'routes/setup/setup.html'
    controller: 'SetupCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise false
  $urlRouterProvider.otherwise '/'
  $locationProvider.html5Mode true