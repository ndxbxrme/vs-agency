'use strict'

angular.module 'vs-agency'
.directive 'progression', (progressionPopup, $timeout, $http) ->
  restrict: 'AE'
  templateUrl: 'directives/progression/progression.html'
  replace: true
  link: (scope, elem) ->
    drawConnection = (ctx, item, prev) ->
      ctx.beginPath()
      if item.offsetLeft > prev.offsetLeft
        ctx.moveTo item.offsetLeft + (item.clientWidth / 2) - 20, item.offsetTop + 20
        ctx.lineTo prev.offsetLeft + (prev.clientWidth / 2) + 20, prev.offsetTop + 20
      else
        ctx.moveTo prev.offsetLeft + (prev.clientWidth / 2) + 20, prev.offsetTop + 20
        ctx.lineTo prev.offsetLeft + (prev.clientWidth / 2) + 40, prev.offsetTop + 20

      ctx.strokeStyle = '#999999'
      ctx.stroke()
    resize = (elem) ->      
      $timeout ->
        c = $('canvas', elem)
        p = $('.milestones', elem)
        ctx = c[0].getContext '2d'
        c[0].width = p[0].clientWidth
        c[0].height = p[0].clientHeight
        items = $('.milestone', elem)
        for item in items
          prev = $(item).prev()[0]
          if $(item).parent().hasClass('branch')
            prev = $(item).parent().prev()[0]
          if prev
            if $(prev).hasClass('milestone')
              drawConnection ctx, item, prev
            else if $(prev).hasClass('branch')
              branchItems = $('.milestone', prev)
              for branchItem in branchItems
                drawConnection ctx, item, branchItem
    index = 0
    scope.getIndex = ->
      index++
    scope.addMilestone = (branch) ->
      if not branch
        branch = []
        scope.progression.milestones.push branch
      branch.push
        title: 'New Milestone'
        notes: []
        todos: []
        estDays: 0
      scope.resize()
    scope.saveProgression = ->
      progressionPopup.hide()
      scope.progressions.save(scope.progression)
      scope.editing = false
      scope.resize()
    scope.cancel = ->
      progressionPopup.hide()
      scope.progressions.refreshFn()
      scope.editing = false
      scope.resize()
    scope.remove = ->
      scope.property.item.$case.item.progressions.remove scope.progression
      scope.property.item.$case.save()
    scope.moveUp = ->
      scope.property.item.$case.item.progressions.moveUp scope.progression
      scope.property.item.$case.save()
    scope.moveDown = ->
      scope.property.item.$case.item.progressions.moveDown scope.progression
      scope.property.item.$case.save()
    scope.resize = ->
      resize elem
    scope.resize()
    window.addEventListener 'resize', scope.resize
    scope.$on '$destroy', ->
      window.removeEventListener 'resize', scope.resize