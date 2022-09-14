'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'client-management-list',
    url: '/client-management'
    templateUrl: 'routes/client-management-list/client-management-list.html'
    controller: 'ClientManagementListCtrl'
    data:
      title: 'Vitalspace Conveyancing - Client Management'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])