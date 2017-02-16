'use strict'

angular.module 'vsAgency'
.directive 'contactDetails', ->
  restrict: 'AE'
  templateUrl: 'directives/contact-details/contact-details.html'
  replace: true
  scope:
    title: '@'
  link: (scope, elem, attrs) ->
    scope.editing = false
    fieldName = _.str.camelize(_.str.slugify(scope.title))
    scope.edit = ->
      scope.editing = true
    scope.data = ->
      property = scope.$parent.getProperty()
      if property and property.case
        if not property.case[fieldName]
          property.case[fieldName] = {}
        return property.case[fieldName]
    scope.confirm = ->
      #save to database
      scope.editing = false
        