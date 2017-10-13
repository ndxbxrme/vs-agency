'use strict'

angular.module 'vs-agency'
.directive 'dateInput', ($filter, $timeout) ->
  require: 'ngModel'
  scope:
    ngModel: '='
  link: (scope, elem, attrs, ctrl) ->
    date = null
    ctrl.$parsers.push (val) ->
      date = interpretDate.interpretText val
      if date
        date.valueOf()
        ctrl.$setValidity 'date', true
      else
        if val
          ctrl.$setValidity 'date', false
      val
    ctrl.$formatters.push (val) ->
      if Object.prototype.toString.call(val) is '[object Number]'
        date = new Date(val)
      if val and date
        if attrs.min
          ctrl.$setValidity 'min', date.valueOf() >= +attrs.min
        if attrs.max
          ctrl.$setValidity 'max', date.valueOf() <= +attrs.max
        ctrl.$setValidity 'date', true
      else
        ctrl.$setValidity 'min', true
        ctrl.$setValidity 'max', true
        ctrl.$setValidity 'date', true
      $filter('date')(val, 'mediumDate')
    blur = ->
      $timeout ->
        if date
          scope.ngModel = date.valueOf()
        else
          scope.ngModel = null
        ctrl.$render()
    elem[0].addEventListener 'blur', blur
    scope.$on '$destroy', ->
      elem[0].removeEventListener 'blur', blur