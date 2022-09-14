'use strict'

angular.module 'vs-agency'
.filter 'getFees', ->
  (property) ->
    return if not property
    return if not property.Fees[0]
    if property.Fees[0].FeeValueType.DisplayName is 'Percentage'
      return +property.Price.PriceValue * (+property.Fees[0].DefaultValue / 100)
    else
      return property.Fees[0].DefaultValue