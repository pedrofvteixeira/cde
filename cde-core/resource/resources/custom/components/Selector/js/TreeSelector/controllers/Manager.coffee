'use strict'
###*
# @module TreeSelector
# @submodule Controllers
###
do (
  _ = _
  TreeSelector = TreeSelector
  Controllers = TreeSelector.Controllers
  Tree = TreeSelector.Models.Tree
) ->
  'use strict'
  ###*
  # Controller responsible for managing the hierarchy of views and controllers.
  #
  # When data is added to the model, the Manager reacts by creating
  # the appropriate views and respective controllers
  #
  # @class Manager
  # @constructor
  # @extends Tree
  ###

  Controllers.Manager = Tree.extend
    ID: 'TreeSelector.Controllers.Manager'
    defaults:
      model: null
      view: null
      controller: null
      configuration: null


    constructor: (options) ->
      this.base.apply this, arguments
      @updateChildren()
      return this


    initialize: (options) ->
      if not @get('view')?
         @addViewAndController @get('model')
      @applyBindings()
      return this

    close: ->
      @get('view')
        #.stopListening()
        #.off()
        .close()

      @get('controller')
        .stopListening() # disconnect from view
        .off() # disconnect from view

      # @get('model')
      #   .stopListening()
      #   .off()

      @stopListening()
      @off()
      @clear()
      return this


    applyBindings: ->
      # throttle functions
      that = this

      throttleScroll = (f) ->
        throttleTimeMilliseconds = that.get('configuration').pagination.throttleTimeMilliseconds
        return _.throttle f, throttleTimeMilliseconds or 0,
          trailing: false

      throttleFilter = (f) ->
        throttleTimeMilliseconds = that.get('view').config.view.throttleTimeMilliseconds
        return _.throttle f, throttleTimeMilliseconds or 0,
          leading: false


      ###*
      # Declare bindings to model and view
      ###
      bindings =
        model:
          'add': @onNewData
          'change:selectedItems' : @onApply
          # 'selection0': _.throttle @sortSiblings, 200,
          #   leadingEdge: false
          'selection': @sortSiblings
        view:
          'filter':  throttleFilter @onFilterChange
          'scroll:reached:top': throttleScroll @getPreviousPage
          'scroll:reached:bottom': throttleScroll @getNextPage

      ###*
      # Create listeners
      ###

      that = this
      _.each bindings, (bindingList, object) ->
        _.each bindingList, (method, event) ->
          that.listenTo that.attributes[object], event, _.bind(method, that)

      @on 'post:child:selection request:child:sort', @sortChildren
      @on 'post:child:add', _.throttle @onUpdateChildren, 1000,
        leading: false

      return this


    addViewAndController: (newModel) ->
      ###*
      # Decide which view to use
      ###
      shareController = true
      if @parent()?
        ###*
        # This node is either a Group or an Item
        # Use the parent's configuration
        ###
        that = @parent()
        configuration = that.get('configuration')
        childConfig = configuration[that.get('view').type].view.childConfig
        target = that.get('view').createChildNode()
        if newModel.children()
          View = TreeSelector.Views[childConfig.withChildrenPrototype]
        else
          View = TreeSelector.Views[childConfig.withoutChildrenPrototype]
        Controller = TreeSelector.Controllers.RootCtrl
        controller = that.get 'controller'
      else
        ###*
        # This node is the Root.
        # A configuration object must have been passed as an option
        ###
        configuration = @get('configuration')
        target = configuration.target
        View = TreeSelector.Views.Root
        Controller = TreeSelector.Controllers.RootCtrl
        controller = null

      ###*
      # Create new view
      ###
      newView = new View
        model: newModel
        configuration: configuration
        target: target
      @set 'view', newView

      ###*
      # Reuse the existing controller, or create a new one, if needed
      ###
      if shareController is true and controller isnt null
        newController = controller
        newController.bindToView newView
      else
        newController = new Controller
          model: newModel
          view: newView
          configuration: configuration
      @set 'controller', newController

      @debug "addViewAndController is done for #{newModel.get('id')} : #{newModel.get('label')}"
      return this


    onNewData: (item, collection, obj) ->
      @debug "New data (#{item.get('label')}) caught by #{@get('model').get('label')}"
      itemParent = @where(
        model: item.parent()
      )
      if itemParent.length is 1
        itemParent[0].trigger "post:child:add"

    onUpdateChildren: ->
      @debug "New data added to #{@get('model').get('label')} : updating children"
      @updateChildren()
      @restoreScroll()
      @trigger 'post:update:children', this

    restoreScroll: ->
      if @get('view')._scrollBar?
        @debug "This group has a scrollbar"
        if @previousPosition?
          @debug "Scrolling back"
          #@get('view')._scrollBar.scrollIntoView  @previousPosition
          @get('view').setScrollBarAt @previousPosition
          @previousPosition = null

    ###*
    # Pagination
    ###

    getNextPage: (model, event) ->
      sorter = @getSorter()
      if _.isFunction sorter
        orderedChildren = @children().sortBy (m, idx) ->
          return sorter m.get('model'), idx
        @previousPosition = _.last(orderedChildren, 2)[0]?.get('view').$el
      #   page = _.last(orderedChildren).get('model').get('page')
      # else
      #   page = model.children().last().get('page')

      # if _.isFinite(page)
      #   page += 1
      # @getPage page, model, event
      @getPage 'next', model, event


    getPreviousPage: (model, event) ->
      sorter = @getSorter()
      if _.isFunction sorter
        orderedChildren = @children().sortBy (m, idx) ->
          return sorter m.get('model'), idx
        @previousPosition = _.first(orderedChildren, 2)[1]?.get('view').$el
      #   page = _.first(orderedChildren).get('model').get('page')
      # else
      #   page = model.children().first().get('page')

      # if _.isFinite(page) and page > 1
      #   page -= 1
      # @getPage page, model, event
      @getPage 'previous', model, event


    getPage: (page, model, event) ->
      @debug "Item #{model.get('label')} requested page #{page}"
      deferred = @requestPage page, @_searchPattern
      return deferred


    requestPage: (page, searchPattern) ->
      getPage = @get('configuration').pagination.getPage
      if not _.isFunction getPage
        return this
      that = this
      deferred = getPage page, searchPattern
        .then (json) ->
          if json.resultset?
            that.debug "getPage: got #{json.resultset.length} more items"
          else
            that.debug "getPage: no more items"
      return deferred


    ###*
    # Child management
    ###


    updateChildren: ->
      models = @get('model').children()
      if models?
        models.each (m) =>
          if @children()
            hasModel = _.any @children().map( (child) ->
              return child.get('model') is m
            )
          else
            hasModel = false
          if not hasModel
            @debug "adding child model #{m.get('label')}"
            @addChild m
        @sortChildren()
        @get('view').updateScrollBar()
      return this

    ###*
    # Create a new manager for this MVC tuple
    # @method addChild
    # @chainable
    ###
    addChild: (newModel) ->
      newManager =
        model: newModel
        configuration: @get('configuration')
      @add newManager
      return this


    removeChild: (model) ->
      throw new Error "NotImplemented"
      return this


    sortSiblings: (model) ->
      @debug "sortSiblings: #{@get('model').get('label')} was triggered
      from #{model.get('label')}:#{model.getSelection()}"
      unless @get('model') is model
        return this
      if @parent()
        @parent().trigger 'request:child:sort'

    getSorter: ->
      type = @children().first().get('view').type
      customSorter = @get('configuration')[type].sorter
      if not customSorter
        return undefined

      configuration = @get('configuration')
      if _.isFunction customSorter
        return (model, idx) ->
          customSorter null, model, configuration
      else if _.isArray customSorter
        ###*
        # Use multiple sorters, one after the other
        ###
        return (model, idx) ->
          return _.chain(customSorter)
            .map (sorter) ->
              return sorter null, model, configuration
            .join('')
            .value()

    sortChildren: ->
      unless @children()
        return this

      customSorter = @getSorter()
      if _.isFunction customSorter
        sorter = (child, idx) ->
          return customSorter child.item.get('model'), idx
        $nursery = @get('view').getChildrenContainer()
        $nursery.hide()
        children = @_detachChildren()
        orderedChildren = _.sortBy children, sorter
        @_appendChildren orderedChildren
        $nursery.show()
      return this

    _detachChildren: ->
      if @children()
        children = @children().map (child) ->
          result =
            item: child
            target: child.get('view').$el.detach()
          return result
      else
        children = null
      return children

    _appendChildren: (children) ->
      if children?
        _.each children, (child) =>
          @get('view').appendChildNode child.target
      return this



    ###*
    # React to the user typing in the search box
    # @method onFilterChange
    # @param {String} text
    # @for Manager
    ###
    onFilterChange: (text) ->
      @_searchPattern = text.trim().toLowerCase()
      filter = _.bind( ->
        isMatch = @filter @_searchPattern
        # prevent this group/root to be hidden in case there are no matches
        @get('model').setVisibility true
      , this)

      if @get('configuration').search.serverSide is true
        that = this
        @requestPage 0, @_searchPattern
          .then ->
            _.defer filter
            return

      _.defer filter
      return

    filter: (text, prefix) ->
      ###*
      # decide on item visibility based on a match to a filter string
      # The children are processed first in order to ensure the visibility is reset correctly
      # if the user decides to delete/clear the search box
      ###

      # _prefix = @get('model').get('label')
      # if prefix
      #   _prefix = prefix + _prefix

      fullString = _.chain ['label']
        .map (property) =>
          return @get('model').get property
        .compact()
        .value()
        .join(' ')

      if prefix
        fullString = prefix + fullString


      if @children()
        isMatch = _.any @children().map (manager) ->
          childIsMatch = manager.filter text, fullString
          manager.get('model').setVisibility childIsMatch
          return childIsMatch

      else if _.isEmpty text
        isMatch = true
      else
        isMatch = fullString.toLowerCase().match(text.toLowerCase())?
        @debug "fullstring  #{fullString} match to #{text}: #{isMatch}"
      @get('model').setVisibility isMatch

      return isMatch


    ###*
    # Management of selected items
    ###
    onApply: (model) ->
      @onFilterChange ''

  return # end of IIFE
