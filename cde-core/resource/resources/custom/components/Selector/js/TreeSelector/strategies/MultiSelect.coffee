'use strict'

do (SelectionStrategies = TreeSelector.SelectionStrategies) ->
  'use strict'
  ###*
  # @module TreeSelector
  # @submodule SelectionStrategies
  ###


  ###*
  # Multiple Selection
  #  - any number of items can be selected
  #
  # @class MultiSelect
  # @extends AbstractSelect
  # @constructor
  ###
  SelectionStrategies.MultiSelect = SelectionStrategies.AbstractSelect.extend
    ID: 'TreeSelector.SelectionStrategies.MultiSelect'
    setSelection: (newState, model) ->
      model.setAndUpdateSelection newState
      return newState


  ###*
  # Limited (Multiple) Selection
  #  - any number of items can be selected, up to a limit
  #
  # @class LimitedSelect
  # @extends AbstractSelect
  # @constructor
  # @param {Object} options
  ###
  SelectionStrategies.LimitedSelect = SelectionStrategies.MultiSelect.extend
    ID: 'TreeSelector.SelectionStrategies.LimitedSelect'
    constructor: (options) ->
      @selectionLimit = options.limit or Infinity

    setSelection: (newState, model) ->
      allow = true
      oldState = model.getSelection()
      newState = @getNewState oldState

      if newState isnt TreeSelector.Enum.select.NONE
        # make sure the model is updated
        selectedItems = model.root().get 'numberOfSelectedItems'
        if not _.isFinite selectedItems
          model.update()
          selectedItems = model.root().get 'numberOfSelectedItems'

        if selectedItems >= @selectionLimit
          @warn "Cannot allow the selection of  \"#{model.get('label')}\".
          Selection limit of #{@selectionLimit} has been reached."
          allow = false
        else
          if model.children()
            if newState is TreeSelector.Enum.select.ALL
              numberOfUnselectedItems = model.flatten()
                .filter (m) -> return not m.children()?
                .filter (m) -> return m.getSelection() is TreeSelector.Enum.select.NONE
                .value()
                .length
              if selectedItems + numberOfUnselectedItems >= @selectionLimit
                @warn "Cannot allow the selection of \"#{model.get('label')}\".
                Selection limit of #{@selectionLimit} would be reached."
                allow = false
                #model.update()

      if allow
        @debug "setSelection"
        model.setAndUpdateSelection newState
        selectedItems = model.root().get 'numberOfSelectedItems'
        model.root().set "reachedSelectionLimit", selectedItems >= @selectionLimit
      else
        newState = oldState
      return newState
