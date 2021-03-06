'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider
  .state 'dashboard',
    url: '/dashboard'
    templateUrl: 'routes/dashboard/dashboard.html'
    controller: 'DashboardCtrl'
    data:
      title: 'Vitalspace Conveyancing - Dashboard'
    resolve:
      user: (Auth) ->
        Auth.getPromise()