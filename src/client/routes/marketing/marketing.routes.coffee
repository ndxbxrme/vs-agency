'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'marketing',
    url: '/marketing'
    templateUrl: 'routes/marketing/marketing.html'
    controller: 'MarketingCtrl'
    data:
      title: 'Vitalspace Conveyancing - Marketing Forms'
      hideMenu: true
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])