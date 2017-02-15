'use strict'

angular.module 'vsAgency'
.directive 'login', (auth, $http, $location, dezrez) ->
  restrict: 'AE'
  templateUrl: 'directives/login/login.html'
  replace: true
  scope: {}
  link: (scope, elem) ->
    scope.getUser = auth.getUser
    
    scope.login = ->
      scope.submitted = true
      if scope.loginForm.$valid
        $http.post '/api/login',
          email: scope.email
          password: scope.password
        .then (response) ->
          auth.getPromise()
          .then ->
            if auth.getDezrezUser()
              dezrez.refresh()
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
          auth.getPromise()
          .then ->
            if auth.getDezrezUser()
              dezrez.refresh()
            $location.path '/loggedin'
        , (err) ->
          scope.message = err.data
          scope.submitted = false 