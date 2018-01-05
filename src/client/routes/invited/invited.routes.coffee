'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'invited',
    url: '/invited'
    templateUrl: 'routes/invited/invited.html'
    controller: 'InvitedCtrl'
    data:
      title: 'Vitalspace Conveyancing - Invited'