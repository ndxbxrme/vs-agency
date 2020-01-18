'use strict'

angular.module 'vs-agency'
.controller 'MarketingCtrl', ($scope, $state, env, $http) ->
  hideMenu = $state.current.data.hideMenu
  $scope.submit = ->
    $scope.submitted = true
    if $scope.newSalesEmail.$valid
      $http.post '/api/properties/send-new-sales-email',
        newsalesemail: $scope.newSalesEmail
      .then ->
        $scope.emailSent = true
    if $scope.reductionEmail.$valid
      $http.post '/api/properties/send-reduction-email',
        reductionemail: $scope.reductionEmailEmail
      .then ->
        $scope.emailSent = true