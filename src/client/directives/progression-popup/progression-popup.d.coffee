'use strict'

angular.module 'vs-agency'
.directive 'progressionPopup', ($rootScope, $timeout, progressionPopup) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-popup/progression-popup.html'
  replace: true
  scope: {}
  link: (scope, elem) ->
    addingNote = false
    scope.action = null
    scope.editorState = ''
    scope.icons = [
      'cathead'
      'house'
      'epc'
      'instruction'
      'draft'
      'fandf'
      'survey'
      'offer'
      'raised'
      'satisfied'
      'applied'
      'complete'
      'report'
      'exchange'
      'invoice'
      'completion'
    ]
    scope.contactOptions = [
      {id:'purchaser',name:'Purchaser'}
      {id:'vendor',name:'Vendor'}
      {id:'purchaserSolicitor',name:'Purchaser\'s solicitor'}
      {id:'vendorSolicitor',name:'Vendor\'s solicitor'}
      {id:'negotiator',name:'Negotiator'}
      {id:'allagency',name:'All agency users'}
      {id:'alladmin',name:'All admin users'}
    ]
    scope.emailTemplates = [
      {id:'default',name:'Default'}
    ]
    scope.smsTemplates = [
      {id:'default',name:'Default'}
    ]
    scope.getData = progressionPopup.getData
    scope.getTitle = progressionPopup.getTitle
    scope.setCompleted = progressionPopup.setCompleted
    scope.getCompleted = progressionPopup.getCompleted
    scope.getCompletedTime = progressionPopup.getCompletedTime
    scope.getProgressing = progressionPopup.getProgressing
    scope.getHidden = progressionPopup.getHidden
    scope.getNotes = progressionPopup.getNotes
    scope.hide = progressionPopup.hide
    scope.getProgressions = progressionPopup.getProgressions
    scope.getDate = progressionPopup.getDate
    scope.setDate = ->
      $rootScope.$emit 'swiper:show', progressionPopup.getDate()
    scope.setProgressing = ->
      progressionPopup.setProgressing()
    getDateDiff = (startDate, endDate) ->
      end = moment(endDate)
      start = moment(startDate).startOf('day')
      nodays = end.diff start, 'days'
      nodays + if nodays is 1 then ' day' else ' days'
    scope.getEstDays = ->
      date = progressionPopup.getDate()
      start = progressionPopup.getStartDate()
      estDays = progressionPopup.getEstDays()
      if date
        getDateDiff start, date
      else
        date = moment().startOf('day').add(estDays, 'day')._d
        progressionPopup.setDate date
        getDateDiff start, date
      
    scope.isStart = ->
      title = progressionPopup.getTitle()
      title is 'Start'
    scope.addNote = ->
      addingNote = true
    scope.addingNote = ->
      addingNote
    scope.doAddNote = ->
      progressionPopup.addNote scope.note
      scope.note = ''
      addingNote = false
    scope.cancelAddNote = ->
      scope.note = ''
      addingNote = false
      
    scope.getMilestones = (progression) ->
      output = []
      for branch in progression.milestones
        for milestone in branch
          output.push milestone
      output
      
    scope.addAction = (action) ->
      console.log scope.actionForm
      if action.type is 'Trigger'
        action.name = action.triggerAction or 'Start milestone'
      else
        action.name = action.template
      if not action._id
        action._id = scope.generateId 8
        scope.getData().actions.push action
      scope.action = null
      scope.editingAction = false
    scope.editAction = (action) ->
      scope.action = action
      scope.editingAction = true
    scope.cancelAction = ->
      scope.action = null
      scope.editingAction = false
      
    scope.reset = ->
      scope.action = null
      scope.editingAction = false
      
    deregister = $rootScope.$on 'set-date', (e, date) ->
      progressionPopup.setDate date
    scope.$on '$destroy', ->
      deregister()