'use strict'
do (
  $ = $
  Extensions = TreeSelector.Extensions
) ->
  $.extend true, Extensions.Sorters,
    selectedOnTop: (model, idx) ->
      #console?.log? "Selected on top"
      result = if model.getSelection() then 'A' else 'Z'
      result += idx

    sameOrder: (model, idx) ->
      result = idx

    sortAlphabetically: (model, idx) ->
      result = model.get 'label'

    sortByValue: (model, idx) ->
      result = -(model.get 'value') or 0
