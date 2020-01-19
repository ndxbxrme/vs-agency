'use strict'

angular.module 'vs-agency'
.controller 'MarketingCtrl', ($scope, $state, env, $http) ->
  hideMenu = $state.current.data.hideMenu
  $scope.submitNewSales = ->
    $scope.submitted = true
    if $scope.newSalesEmail.$valid
      $http.post '/api/properties/send-new-sales-email',
        newsalesemail: $scope.newSalesEmail
      .then ->
        $scope.salesEmailSent = true
        $scope.submitted = false
  $scope.submitReduction = ->
    $scope.submitted = true
    if $scope.reductionEmail.$valid
      $http.post '/api/properties/send-reduction-email',
        reductionemail: $scope.reductionEmailEmail
      .then ->
        $scope.reductionEmailSent = true
        $scope.submitted = false
