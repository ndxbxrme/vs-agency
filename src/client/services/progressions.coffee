'use strict'

angular.module 'vsAgency'
.factory 'progressions', ($http, alert) ->
  progressions = []
  fetchProgressions = ->
    $http.get '/api/progressions'
    .then (response) ->
      progressions = response.data
    , (err) ->
      false
    true
  refresh: ->
    fetchProgressions()
  getProgressions: ->
    progressions
  getProgression: (id) ->
    for progression in progressions
      if progression._id is id
        return progression
  saveProgression: (progression) ->
    $http.post '/api/progression', progression
    .then (response) ->
      alert.log 'Progression saved'
    , (err) ->
      false