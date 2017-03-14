'use strict'

angular.module 'vs-agency'
.directive 'contactDetails', ->
  restrict: 'EA'
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
      property = scope.$parent.property
      if property and property.item and property.item.$case and property.item.$case.item
        if not property.item.$case.item[fieldName]
          property.item.$case.item[fieldName] = {}
        return property.item.$case.item[fieldName]
    scope.confirm = ->
      #save to database
      scope.$parent.property.item.$case.save()
      scope.editing = false