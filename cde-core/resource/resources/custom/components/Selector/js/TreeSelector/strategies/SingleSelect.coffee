'use strict'
do (SelectionStrategies = TreeSelector.SelectionStrategies) ->
  'use strict'
  ###*
  # @module TreeSelector
  # @submodule SelectionStrategies
  ###

  ###*
  # Single Selection
  #  - only one item can be selected at any time
  # @class SingleSelect
  # @extends AbstractSelect
  # @constructor
  ###
  SelectionStrategies.SingleSelect = SelectionStrategies.AbstractSelect.extend
    ID: 'TreeSelector.SelectionStrategies.SingleSelect'

    setSelection: (newState, model) ->
      if model.children()
        return

      if @isLogicGlobal is true
        model.root().setSelection TreeSelector.Enum.select.NONE
      else if model.getSelection() isnt TreeSelector.Enum.select.ALL
        # local logic, i.e. within a group
        if model.parent()
          model.parent().setSelection TreeSelector.Enum.select.NONE

      # set and propagate the changes globally
      model.setAndUpdateSelection TreeSelector.Enum.select.ALL
      return newState

    changeSelection: (model) ->
      @base model
      @applySelection model
