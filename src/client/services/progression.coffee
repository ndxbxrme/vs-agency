'use strict'

angular.module 'vsAgency'
.factory 'progression', ($timeout) ->
  drawConnection = (ctx, item, prev) ->
    ctx.beginPath()
    ctx.moveTo item.offsetLeft + (item.clientWidth / 2) - 20, item.offsetTop + 20
    ctx.lineTo prev.offsetLeft + (prev.clientWidth / 2) + 20, prev.offsetTop + 20
    ctx.strokeStyle = '#999999'
    ctx.stroke()
  resize: (elem) ->      
    $timeout ->
      c = $('canvas', elem)
      p = $('.progression', elem)
      ctx = c[0].getContext '2d'
      c[0].width = p[0].clientWidth
      c[0].height = p[0].clientHeight
      items = $('.progression-item', elem)
      for item in items
        prev = $(item).prev()[0]
        if $(item).parent().hasClass('branch')
          prev = $(item).parent().prev()[0]
        if prev
          if $(prev).hasClass('progression-item')
            drawConnection ctx, item, prev
          else if $(prev).hasClass('branch')
            branchItems = $('.progression-item', prev)
            for branchItem in branchItems
              drawConnection ctx, item, branchItem