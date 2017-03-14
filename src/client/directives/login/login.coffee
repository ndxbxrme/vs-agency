'use strict'

angular.module 'vs-agency'
.directive 'login', ($http, $location, $state) ->
  restrict: 'AE'
  templateUrl: 'directives/login/login.html'
  replace: true
  scope: {}
  link: (scope, elem) ->
    scope.hideLogin = ->
      $state.current.name is 'invited'
    scope.login = ->
      scope.submitted = true
      if scope.loginForm.$valid
        $http.post '/api/login',
          email: scope.email
          password: scope.password
        .then (response) ->
          scope.auth.getPromise()
          .then ->
            $location.path '/loggedin'
        , (err) ->
          scope.message = err.data
          scope.submitted = false
    scope.signup = ->
      scope.submitted = true
      if scope.loginForm.$valid
        $http.post '/api/signup',
          email: scope.email
          password: scope.password
        .then (response) ->
          scope.auth.getPromise()
          .then ->
            $location.path '/loggedin'
        , (err) ->
          scope.message = err.data
          scope.submitted = false 