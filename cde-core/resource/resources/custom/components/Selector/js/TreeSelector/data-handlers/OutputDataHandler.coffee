do (_ = _,
  BaseModel = BaseModel,
  LoggerMixin = TreeSelector.Logger,
  DataHandlers = TreeSelector.DataHandlers
) ->
  'use strict'
  ###*
  # @module TreeSelector
  # @submodule DataHandlers
  ###


  ###*
  # The Output DataHandler:
  # - watches the model for specific changes
  # - synchronizes CDF with the model
  # If you squint, you can see that it behaves like a View,
  # except that it writes to a CDF parameter
  # @class Output
  # @extends BaseModel
  # @uses Logger
  # @constructor
  # @param {Object} options
  ###
  DataHandlers.Output = BaseModel.extend(LoggerMixin).extend

    ID: 'TreeSelector.DataHandlers.Output'


    initialize:  ->
      if true or @attributes.options.trigger is 'apply'
        @listenTo @get('model'), 'change:selectedItems', @onApply
      else
        @listenTo @get('model'), 'change:isSelected', @onSelection
      return this


    _processOutput: (model, selection) ->
      result = undefined

      if _.isFunction @attributes.options.outputFormat
        modifiedSelection = @attributes.options.outputFormat.call this, model,selection
        result = if not _.isUndefined modifiedSelection then modifiedSelection
      else
        if _.isString @attributes.options.outputFormat
          switch @attributes.options.outputFormat.toLowerCase()
            when 'lowestid'
              result = @getLowestId selection
            when 'highestid'
              result = @getHighestId selection
            when 'selected'
              result = selection

      if _.isUndefined result
        result = @getLowestId selection
      return result

    ###*
    # Process the list of selected items and attempt to produce a compact array,
    # in which a single id is user to represent all the members of a fully
    # selected group
    # @method getHighestId
    # @for Output
    # @private
    # @params {Object} selectionState
    # @return {Array} Returns a list of ids
    ###
    getHighestId: (selectionState) ->
      ###*
      # If a node with children is set to "all", return self and omit the children
      ###
      list = _.chain( selectionState.all )
        .filter (m) -> return not _.isUndefined m.get('id')
        .filter (m, idx, models) ->
          isParent = not _.contains(models, m.parent())
          return isParent
        .map (m) -> return m.get 'id'
        .value()
      return list


    ###*
    # Process the list of selected items and produce a list of the ids of
    # the selected items (leafs only)
    # @method getLowestId
    # @for Output
    # @private
    # @params {Object} selectionState
    # @return {Array} Returns a list of ids
    ###
    getLowestId: (selectionState) ->
      ###*
      # Return the id of selected children. Group ids are ignored
      ###
      list = _.chain( selectionState.all )
        .filter (m, idx, models) -> return not m.children()
        .map (m) -> return m.get 'id'
        .value()
      return list


    onApply: (model, selectionState) ->
      unless selectionState?
        return this

      treatedSelection = @_processOutput model, selectionState
      @debug "confirmed selection:" + treatedSelection
      @trigger 'changed', treatedSelection
      return this


    onSelection: (model) ->
      @debug "onSelection: " + model.get 'label'
      #treatedSelection = @_processOutput selection, model
      #@trigger 'changed', treatedSelection
      return this

    ###*
    # Reads the selection state from the model and transforms this information
    # into the format the CDF selector is expecting to consume
    # @method getValue
    # @public
    # @return {Array|Object} Returns the currently committed selection state
    ###
    getValue: ->
      model = @get('model')
      selection = model.root().get 'selectedItems'
      treatedSelection = @_processOutput selection, model
      return treatedSelection

   return #IIFE
