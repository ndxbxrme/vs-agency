'use strict'

angular.module 'vsAgency'
.directive 'contactDetails', ->
  restrict: 'AE'
  templateUrl: 'directives/contact-details/contact-details.html'
  replace: true
  scope:
    title: '@'
  link: (scope, elem, attrs) ->