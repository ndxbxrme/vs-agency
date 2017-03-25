'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'template',
    url: '/template/:id/:type'
    templateUrl: 'routes/template/template.html'
    controller: 'TemplateCtrl'
    resolve:
      user: (auth) ->
        auth.getPromise(['admin', 'superadmin'])