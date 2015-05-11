'use strict'

do (
  _ = _
  TreeSelector = TreeSelector
  Models = TreeSelector.Models
  Tree = TreeSelector.Models.Tree
) ->
  'use strict'
  ###*
  # Represents the state of the selector as tree structure.
  #
  # @module TreeSelector
  # @submodule Models
  # @class SelectionTree
  # @constructor
  # @extends Tree
  ###

  Models.SelectionTree = Tree.extend
    ###*
    # @property {Object} [defaults]
    # @private
    # Default values for each node in the selection tree
    ###
    defaults:
      id: undefined
      label: "Label"
      isSelected: false
      isVisible: true
      isCollapsed: true
      numberOfSelectedItems: 0
      numberOfItems: 0
      page: 0


    constructor: (attributes, options) ->
      if attributes?.label?
        if not attributes.id? or (options?.useValueAsId is true)
          attributes.id = attributes.label
      this.base attributes, options


    initialize: ->
      this.base.apply this, arguments
      @on 'add remove', @update


    sync: (action, model, options) ->
      @log "Please #{action} item #{model.get('label')}"
      _.each model.where({ isSelected: true }), (m) ->
        @log "Processing #{action} on item #{m.get('label')}"

    ###*
    # sets the selection state of the model
    # @method setSelection
    # @public
    ###
    setSelection: (newState) ->

      # change selection only if the new state is different
      if @getSelection() is newState
        return this

      # update self
      @set 'isSelected', newState#, {silent: true}

      # update children
      if newState isnt TreeSelector.Enum.select.SOME
        if @children()
          @children().each (child) ->
            child.setSelection newState

      # propagate any changes to a global context
      if @parent()
        @parent().updateSelection()
      return this

    ###*
    # gets the selection state of the model
    # @method getSelection
    # @public
    # @return {Boolean}
    ###
    getSelection: ->
      return @get 'isSelected'

    setAndUpdateSelection: (newState) ->
      @setSelection newState
      @update()
      @trigger 'selection', this

    setVisibility: (newState) ->
      isVisible = @get 'isVisible'
      if isVisible isnt newState
        @set 'isVisible', newState

    getVisibility: ->
      return @get 'isVisible'


    getSelectedItems: (field) ->
      getMyself = =>
        value = @get(field or 'id')
        # if _.isUndefined value
        #   value = @get 'label'
        return value


      isSelected = @getSelection()
      switch isSelected
        when TreeSelector.Enum.select.SOME, undefined
          if @children()
            return _.flatten( @children().map (child) ->
              return child.getSelectedItems( field ) or []
            )
          else
            return getMyself()
        when TreeSelector.Enum.select.ALL then getMyself()
        when TreeSelector.Enum.select.NONE then []
        else
          return []

    ###*
    # Mark listed items as selected
    # NOTE: currently acts directly on the model and bypasses any business logic
    # TODO: change implementation to be recursive rather than acting on a flat tree
    # @method setSelectedItems
    ###
    setSelectedItems: (idList) ->
      flatTree = @flatten()
      # First, set childless nodes (items)
      flatTree
        .filter (m) -> return not m.children()?
        .each (m) ->
          id = m.get('id')
          if _.contains idList, id
            m.setSelection TreeSelector.Enum.select.ALL
          else
            m.setSelection TreeSelector.Enum.select.NONE
      # Set nodes with children (groups)
      flatTree
        .filter (m) -> return m.children()?
        .each (m) ->
          id = m.get('id')
          if _.contains idList, id
            m.setSelection TreeSelector.Enum.select.ALL

      # Update model with calculated/inferred values
      @update()
      #@root().set 'selectedItems', @_getSelectionSnapshot(), {silent: true}
      @root().updateSelectedItems {silent: true}

    updateSelectedItems: (options) ->
      @root().set 'selectedItems', @_getSelectionSnapshot(), options

    restoreSelectedItems: ->
      selectedItems = @root().get 'selectedItems'
      unless selectedItems?
        selectedItems =
          none: @flatten()

      selectedItems.none
        #.filter (m) -> return m.children()?
        .each (m) ->
          m.setSelection TreeSelector.Enum.select.NONE

      if selectedItems.all?
        selectedItems.all
          #.filter (m) -> return m.children()?
          .each (m) ->
            m.setSelection TreeSelector.Enum.select.ALL
      @update()


    _getSelectionSnapshot: ->
      flatTree = @flatten()
      selectionSnapshot =
        none: flatTree.filter (m) ->
          return m.getSelection() is TreeSelector.Enum.select.NONE
        some: flatTree.filter (m) ->
          return m.getSelection() is TreeSelector.Enum.select.SOME
        all: flatTree.filter (m) ->
          return m.getSelection() is TreeSelector.Enum.select.ALL
      return selectionSnapshot

    update: ->
      # propagate the changes globally
      @root().updateSelection()

      numberOfServerItems = @root().get 'numberOfItemsAtServer'
      if numberOfServerItems?
        @root().set 'numberOfItems', numberOfServerItems
      else
        @root().updateCountOfItems 'numberOfItems', (model) ->
          return 1

      @root().updateCountOfItems 'numberOfSelectedItems', (model) ->
        return if model.getSelection() is TreeSelector.Enum.select.ALL then 1 else 0
      return this


    updateSelection: ->
      # Update the selection state of nodes with children
      inferParentSelectionStateFromChildren = (childrenStates) ->
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

      @inferSelection inferParentSelectionStateFromChildren, (model, isSelected) ->
        if model.children()
          if model.getSelection() isnt isSelected
            model.setSelection isSelected



    inferSelection: (logic, callback) ->
      ###*
      # calculate the current state based on the state of the children
      # and optionally execute a callback
      ###
      itemCallback = (node) ->
        return node.getSelection()

      bothCallback = (node, result) ->
        if _.isFunction callback
          callback node, result
        return result

      return @walkDown itemCallback, logic, bothCallback

    # inferSelection0: (logic, callback) ->
    #   if @children()
    #     inferredSelection = logic @children().map (child) ->
    #       return child.inferSelection( logic, callback )
    #   else
    #     inferredSelection =  @get 'isSelected'

    #   if _.isFunction callback
    #     callback this, inferredSelection

    #   return inferredSelection



    countItems: (callback) ->
      if @children()
        count = @children().reduce( (memo, child) ->
          return memo + child.countItems(callback)
        0)
      else
        count = callback this
      return count

    updateCountOfItems: (property, callback) ->
      # Update count of selected items for nodes with children
      countItem = (model) ->
        return callback model

      sumItems = (list) ->
        return _.reduce( list, ( (memo, n) ->
          return memo + n
        ), 0)

      setCountOfItems = (model, count) ->
        if model.children()
          model.set property, count
        return count

      @walkDown countItem, sumItems, setCountOfItems


    countSelectedItems: ->
      return  @countItems (model) ->
        return if model.getSelection() is TreeSelector.Enum.select.ALL then 1 else 0

    updateCountOfSelectedItems: ->
      # Update count of selected items for nodes with children
      countSelectedItem = (model) ->
        return if model.getSelection() is TreeSelector.Enum.select.ALL then 1 else 0

      sumSelectedItems = (list) ->
        return _.reduce( list, ( (memo, n) ->
          return memo + n
        ), 0)

      setSelectedItems = (model, count) ->
        if model.children()
          model.set 'numberOfSelectedItems', count
        return count

      @walkDown countSelectedItem, sumSelectedItems, setSelectedItems

    hasChanged: ->
      previousSelection = @get('selectedItems')
      if previousSelection?
        hasChanged = _.any _.map @_getSelectionSnapshot(), (current, state) ->
          previous = previousSelection[state]
          intersection = current.intersection( previous.value() ).value()
          return not ( current.isEqual(intersection).value() and previous.isEqual(intersection).value() )
      else
        hasChanged = false
      return hasChanged


    setBusy: (isBusy) ->
      @root().set 'isBusy', isBusy
      return this

    isBusy: ->
      return @root().get 'isBusy'
