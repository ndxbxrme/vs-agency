'use strict'

angular.module 'vs-agency'
.directive 'progressionPopup', ($rootScope, $timeout, progressionPopup) ->
  restrict: 'AE'
  templateUrl: 'directives/progression-popup/progression-popup.html'
  replace: true
  scope: {}
  link: (scope, elem) ->
    progressionPopup.setScope scope
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
      {id:'purchasersContact',name:'Purchaser'}
      {id:'vendorsContact',name:'Vendor'}
      {id:'purchasersSolicitor',name:'Purchaser\'s solicitor'}
      {id:'vendorsSolicitor',name:'Vendor\'s solicitor'}
      {id:'negotiator',name:'Negotiator'}
      {id:'allagency',name:'All agency users'}
      {id:'alladmin',name:'All admin users'}
    ]
    scope.emailTemplates = scope.list 'emailtemplates'
    scope.smsTemplates = scope.list 'smstemplates'
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
      progressionPopup.getEstDays()
      
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
      
    findByValue = (value, list, valField) ->
      for item in list
        if item[valField or '_id'] is value
          return item
      return {}
      
    scope.addAction = (action) ->
      if action.type is 'Trigger'
        action.name = action.triggerAction or 'Start milestone'
      else
        action.name = findByValue(action.template, (if action.type is 'Email' then scope.emailTemplates.items else scope.smsTemplates.items), '_id').name
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
      
    scope.reset = progressionPopup.reset
      
    deregister = $rootScope.$on 'set-date', (e, date) ->
      progressionPopup.setDate date
    scope.$on '$destroy', ->
      deregister()