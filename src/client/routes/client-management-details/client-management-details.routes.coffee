'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'client-management-details',
    url: '/client-management/:id'
    templateUrl: 'routes/client-management-details/client-management-details.html'
    controller: 'ClientManagementDetailsCtrl'
    data:
      title: 'Vitalspace Conveyancing - Client Management'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['admin', 'superadmin'])