'use strict'
###*
# @module TreeSelector
# @submodule SelectionStrategies
###

do (
  SelectionStrategies = TreeSelector.SelectionStrategies
  Logger = TreeSelector.Logger
  _ = _
) ->
  'use strict'

  ###*
  # Base class for handling the selection logic
  #  - what happens when I click on a particular item
  #  - what rules should be followed
  # @class AbstractSelect
  # @extends Base
  # @uses TreeSelector.Logger
  # @constructor
  ###
  SelectionStrategies.AbstractSelect = Base.extend(Logger).extend
    ID: 'TreeSelector.SelectionStrategies.AbstractSelect'
    constructor: (options) ->
      #@isLogicGlobal = options.isLogicGlobal and false
      @isLogicGlobal = true

    ###*
    # Calculates the new state of an item, after the user clicked on it
    # @method getNewState
    # @public
    # @params {Enum} oldState
    # @return {Enum} Returns the next state
    ###
    getNewState: (oldState) ->
      switch oldState
        when TreeSelector.Enum.select.NONE then TreeSelector.Enum.select.ALL
        when TreeSelector.Enum.select.ALL then TreeSelector.Enum.select.NONE
        when TreeSelector.Enum.select.SOME then TreeSelector.Enum.select.NONE


    ###*
    # Infers the state of a node, based on the current state of its children
    # @method inferSelectionFromChildren
    # @private
    # @params {Array of Enum} childrenStates
    # @return {Enum} Returns the inferred state
    ###
    inferSelectionFromChildren: (childrenStates) ->
      all = _.every childrenStates, (el) ->
        el is TreeSelector.Enum.select.ALL
      none = _.every childrenStates, (el) ->
        el is TreeSelector.Enum.select.NONE

      if all
        return TreeSelector.Enum.select.ALL
      else if none
        return TreeSelector.Enum.select.NONE
      else
        return TreeSelector.Enum.select.SOME


    ###*
    # Sets a node in the selection tree to a particular state
    # @method setSelection
    # @protected
    # @params {Enum} newState
    # @params {Object} model
    # @chainable
    ###
    setSelection: (newState, model) ->
      throw new Error "NotImplemented"
      return this


    ###*
    # Perform operations on the model, associated with the user clicking on an item
    # @method changeSelection
    # @public
    # @params {Object} model
    # @chainable
    ###
    changeSelection: (model) ->
      d = $.now()
      c = TreeSelector.count
      newState = @getNewState model.getSelection()
      newState = @setSelection newState, model

      that = this
      _.delay( ->
        that.debug "Switching #{model.get('label')} to #{newState}
          took #{($.now() - d)} ms and #{TreeSelector.count - c} renders"
      , 0)
      return this


    ###*
    # Perform operations on the model, associated with commiting the current selection
    # @method applySelection
    # @public
    # @params {Object} model
    # @chainable
    ###
    applySelection: (model) ->
      model.updateSelectedItems()
      model.root().set 'isCollapsed', true
      return this
