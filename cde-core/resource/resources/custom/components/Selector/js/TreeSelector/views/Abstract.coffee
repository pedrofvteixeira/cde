'use strict'
###*
# @module TreeSelector
# @submodule Views
###
do (
  $ = $
  _ = _
  BaseView = BaseView
  Mustache = Mustache
  LoggerMixin = TreeSelector.Logger
  Views = TreeSelector.Views
) ->

  ###*
  # Abstract base class for all Views
  # @class Abstract
  # @constructor
  # @extends BaseView
  # @uses TreeSelector.Logger
  ###
  Views.AbstractView = BaseView.extend(LoggerMixin).extend
    # constructor: (options) ->
    #   this.base.apply this, arguments
    #   return this

    initialize: (options) ->
      @configuration = options.configuration
      @config = @configuration[@type]

      ###*
      # Consider user-defined templates
      ###
      if @config.view.templates?
        $.extend true, @template, @config.view.templates

      if @model
        @bindToModel @model
      @setElement options.target
      @render()
      return this


    bindToModel: (model) ->
      # Bind actions common to all views
      @onChange model, 'isVisible', @updateVisibility
      return this


    onChange: (model, properties, callback) ->
      props = properties.split(' ')
      events = _.map( props, (prop) ->
        return 'change:' + prop
      ).join(' ')
      if @config.view.throttleTimeMilliseconds >= 0
        @listenTo model, events, _.throttle(callback, @config.view.throttleTime,
          leading: false
        )
      else
        @listenTo model, events, callback
      return this

    updateSlot: (slot) ->
      return _.bind( ->
        viewModel = @getViewModel()
        renderer = @renderSlot 'slot'
        renderer.call this, viewModel
      , this)

    renderSlot: (slot) ->
      return _.bind( (viewModel) ->
        if @template[slot]
          html = Mustache.render @template[slot], viewModel
          @$( @config.view.slots[slot] ).replaceWith html
        @injectContent slot
        TreeSelector.count++
        #@log "Rendering #{slot} of item #{@model.get('label')} at count #{TreeSelector.count}"
      , this)

    ###*
    # View methods
    ###

    getViewModel: ->
      viewOptions = _.result @config, 'options'
      return $.extend true, @model.toJSON(),
        viewOptions
        strings: _.result @config, 'strings'
        selectionStrategy: _.omit @configuration.selectionStrategy, 'strategy'
        isPartiallySelected: @model.getSelection() is TreeSelector.Enum.select.SOME
        numberOfChildren: if @model.children() then @model.children().length else 0
        # numberOfItems: @model.countItems (leaf) ->
        #   return 1
        # numberOfSelectedItems: @model.countItems (leaf) ->
        #   return if leaf.getSelection() is TreeSelector.Enum.select.ALL then 1 else 0


    injectContent: (slot) ->
      renderers = @config?.renderers?[slot]
      unless renderers?
        return

      @debug "injecting"
      if not _.isArray renderers
        renderers = [ renderers ]

      that = this
      _.each renderers, (renderer) ->
        if _.isFunction renderer
          renderer.call that, that.$el, that.model, that.configuration

      return this

    ###*
    # Fully renders the view
    # @method render
    # @chainable
    ###
    render: ->
      viewModel = @getViewModel()
      @renderSkeleton viewModel
      @renderSelection viewModel
      @updateVisibility viewModel
      return this


    renderSkeleton: (viewModel) ->
      # The skeleton is supposed to be static, so viewModel should not be needed at all
      @$el.html Mustache.render @template.skeleton, viewModel
      TreeSelector.count++
      #@log "Rendering skeleton  of item #{@model.get('label')} at count #{TreeSelector.count}"
      return this


    updateSelection: (model, options) ->
      if model is @model
        viewModel = @getViewModel()
        @renderSelection viewModel
      #@log "#{@model.get('label')} was notified that #{model.get('label')} has changed to #{model.getSelection()}"
      return this


    renderSelection: (viewModel) ->
      html = Mustache.render @template.selection, viewModel
      @$(@config.view.slots.selection).replaceWith html
      @injectContent 'selection'
      TreeSelector.count++
      #@log "Rendering selection of item #{@model.get('label')} at count #{TreeSelector.count}"

    updateVisibility: ->
      if @model.getVisibility()
        @$el.show()
      else
        @$el.hide()

    ###*
    # Children management
    ###
    getChildrenContainer: ->
      return @$ @config.view.slots.children


    createChildNode: ->
      $child = $('<div/>').addClass @config.view.childConfig.className
      $target = @$ @config.view.slots.children
      $child.appendTo $target
      return $child


    appendChildNode: ($child) ->
      $target = @$ @config.view.slots.children
      $child.appendTo $target
      return $child


    ###*
    # Scrollbar methods
    ###
    updateScrollBar: ->
      nItems = @config.options.scrollThreshold
      needsScrollBar = _.isFinite(@configuration.pagination.pageSize) and @configuration.pagination.pageSize > 0
      needsScrollBar = needsScrollBar or @type isnt 'Item' and @model.flatten().size().value() > nItems
      if needsScrollBar
        @log "There are more than #{nItems} items, adding scroll bar"
        @addScrollBar()

    addScrollBar: ->
      if @_scrollBar?
        return this

      @debug "Adding a scrollbar to #{@model.get('label')}"
      that = this
      switch @config.view.scrollbar.engine
        when 'optiscroll'
          @_scrollBar =  @$ @config.view.slots.children
            .addClass 'optiscroll-content'
            .parent()
            .addClass 'optiscroll'
            .optiscroll()
            .off 'scrollreachbottom'
            .on 'scrollreachbottom', (event) ->
              that.trigger 'scroll:reached:bottom', that.model, event
            .off 'scrollreachtop'
            .on 'scrollreachtop', (event) ->
              that.trigger 'scroll:reached:top', that.model, event
            .data 'optiscroll'
        when 'mCustomScrollbar'
          options = $.extend true, {}, @config.view.scrollbar.options,
            callbacks:
              onTotalScroll: ->
                that.trigger 'scroll:reached:bottom', that.model
              onTotalScrollBack: ->
                that.trigger 'scroll:reached:top', that.model
          @_scrollBar =  @$ @config.view.slots.children
            .parent()
            .mCustomScrollbar options


      if @config.options.isResizable
        $container = @$ @config.view.slots.children
          .parent()
        if _.isFunction $container.resizable
          $container.resizable
            handles: 's'
      return this


    setScrollBarAt: ($tgt) ->
      if @_scrollBar?
        @_scrollBar.scrollIntoView $tgt
      return this


    ###*
    # Events triggered by the user
    ###


    onMouseOver: (event) ->
      $node =  @$ @config.view.slots.selection
      $node = @$('div:eq(0)')
      #$node.toggleClass "hover", true
      @trigger 'mouseover', @model
      return this


    onMouseOut: (event) ->
      $node = @$ @config.view.slots.selection
      $node = @$('div:eq(0)')
      #$node.toggleClass "hover", false
      @trigger 'mouseout', @model
      return this


    onSelection: ->
      #@log "view: onSelected"
      @trigger 'selected', @model
      return this


    onApply: (event) ->
      #@log "Apply"
      @trigger 'control:apply', @model
      return this


    onCancel: (event) ->
      @debug "triggered Cancel"
      @trigger 'control:cancel', @model
      return this


    onFilterChange: (event) ->
      text = $(event.target).val()
      @trigger 'filter', text, @model
      return this


    onFilterClear: (event) ->
      text = ''
      @$('.selector-filter-input:eq(0)').val text
      @trigger 'filter', text, @model
      return this


    onToggleCollapse: (event) ->
      @debug "triggered collapse"
      @trigger "toggleCollapse", @model, event
      return this


    ###*
    # Boilerplate methods
    ###
    close: ->
      @remove()
      @unbind()
      # _.each @childViews, (v) ->
      #   v.close()

      ###*
      # Update tree of views
      ###

      # updateChildren:  ->
      #   if _.isEmpty @childConfig
      #     @render()
      #     return this

      #   # keep the childViews for existing models
      #   @childViews = _.filter @childViews, (childView) =>
      #     if _.contains @model.children().models, childView.model
      #       @log "updating view for node " + childView.model.get('label')
      #       childView.updateChildren()
      #       return true
      #     else
      #       childView.close()
      #       return false

      #   _.each @childViews, (v) ->
      #     #v.close()

      #   if not @model.children()
      #     _.each @childViews, (v) ->
      #       v.close()

      #     @childViews = []
      #   else
      #     # only create new views for new models
      #     @model.children().each _.bind( (childModel) ->
      #       modelHasView = _.some @childViews, (childView) ->
      #         return childView.model is childModel

      #       if modelHasView is false
      #         @log "creating child view for model " + childModel.get('label')
      #         if childModel.children()
      #           ChildView = TreeSelector.Views[@childConfig.withChildrenPrototype]
      #         else
      #           ChildView = TreeSelector.Views[@childConfig.withoutChildrenPrototype]
      #         if ChildView?
      #           @childViews.push new ChildView(
      #             model: childModel
      #             content: @configuration
      #             #logic: @logic
      #             controller: @controller
      #           )
      #     this)
      #   @render()
      #   return this
  return
