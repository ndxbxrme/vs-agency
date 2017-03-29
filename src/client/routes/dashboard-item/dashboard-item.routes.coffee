'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'dashboardItem',
    url: '/dashboard-item/:id/:type'
    templateUrl: 'routes/dashboard-item/dashboard-item.html'
    controller: 'DashboardItemCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise(['admin','superadmin'])