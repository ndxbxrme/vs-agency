'use strict'

angular.module 'vs-agency'
.controller 'MarketingCtrl', ($scope, $http) ->
  $scope.submitNewSales = ->
    $scope.submitted = true
    if $scope.newSalesEmail.$valid
      $http.post '/api/properties/send-new-sales-email',
        newSales: $scope.newSales
      .then ->
        $scope.salesEmailSent = true
        $scope.submitted = false
  $scope.submitReduction = ->
    $scope.submitted = true
    if $scope.reductionEmail.$valid
      $http.post '/api/properties/send-reduction-email',
        reduction: $scope.reduction
      .then ->
        $scope.reductionEmailSent = true
        $scope.submitted = false
