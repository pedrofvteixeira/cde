'use strict'
###*
# @module TreeSelector
# @submodule Views
###

do (
  $ = $
  _ = _
  Mustache = Mustache
  Views = TreeSelector.Views
  TreeSelectorTemplates = TreeSelector.templates
) ->
  ###*
  # Root View: the part of the selector that
  # remains visible when the selector is collapsed
  # @class Root
  # @extends AbstractView
  # @constructor
  ###
  Views.Root = Views.AbstractView.extend
    type: 'Root'
    ID: 'TreeSelector.Views.Root'

    template:
      skeleton: TreeSelectorTemplates['Root-skeleton']
      overlay: TreeSelectorTemplates['Root-overlay']
      header: TreeSelectorTemplates['Root-header']
      selection: TreeSelectorTemplates['Root-template']
      footer: TreeSelectorTemplates['Root-footer']

    events:
      'click     .selector-root-header:eq(0)': 'onToggleCollapse'
      #'click     .selector-root-selection-icon:eq(0)': 'onSelection'
      'click     .selector-root-selection:eq(0)': 'onSelection'
      'click     .selector-btn-apply:eq(0)': 'onApply'
      'click     .selector-btn-cancel:eq(0)': 'onCancel'
      'mouseover .selector-root-header': 'onMouseOver'
      'mouseout  .selector-root-header': 'onMouseOut'
      'keyup   .selector-filter:eq(0)': 'onFilterChange'
      'change  .selector-filter:eq(0)': 'onFilterChange'
      'click  .selector-filter-clear:eq(0)': 'onFilterClear'
      'click  .selector-overlay' : 'onOverlayClick'


    initialize: (options) ->
      @renderOverlay = @renderSlot 'overlay'
      @renderHeader = @renderSlot 'header'
      @renderFooter = @renderSlot 'footer'
      return this.base options

    bindToModel: (model) ->
      this.base model
      @onChange model, 'isCollapsed', @updateCollapse
      @onChange model, 'isSelected numberOfSelectedItems numberOfItems reachedSelectionLimit', @updateHeader
      @onChange model, 'isSelected numberOfSelectedItems numberOfItems selectedItems', @updateSelection
      @onChange model, 'reachedSelectionLimit isBusy', @updateFooter
      @onChange model, 'isDisabled', _.bind(@updateAvailability, this)

    getViewModel: ->
      viewModel = @base()
      $.extend viewModel,
        selectedItems: _.map @model.getSelectedItems('label'), (label) -> return label + " "
        allItemsSelected: @model.get('numberOfSelectedItems') is @model.get('numberOfItems')
        noItemsSelected: @model.get('numberOfSelectedItems') is 0
        hasChanged: @model.hasChanged()

      return viewModel

    render: ->
      viewModel = @getViewModel()
      @renderSkeleton viewModel
      @renderOverlay viewModel
      @renderHeader viewModel
      @renderCollapse viewModel
      @renderSelection viewModel
      @renderFooter viewModel
      @renderAvailability viewModel
      return this


    updateHeader: ->
      viewModel = @getViewModel()
      @renderHeader viewModel
      return this

    updateFooter: ->
      viewModel = @getViewModel()
      @renderFooter viewModel
      return this

    updateCollapse: ->
      viewModel = @getViewModel()
      @renderHeader viewModel
      @renderOverlay viewModel
      @renderCollapse viewModel
      return this

    renderCollapse: (viewModel) ->
      if viewModel.isDisabled is true
        @$('.selector-root-container')
          .toggleClass 'expanded', false
          .toggleClass 'collapsed', true
          .toggleClass 'alwaysExpanded', false
      else if viewModel.alwaysExpanded is true
        @$('.selector-root-container')
          .toggleClass 'expanded', false
          .toggleClass 'collapsed', false
          .toggleClass 'always-expanded', true
        #@$( '.selector-filter-input' ).focus()

      else if viewModel.isCollapsed is true
        @$('.selector-root-container')
          .toggleClass 'expanded', false
          .toggleClass 'collapsed', true
          .toggleClass 'always-expanded', false

      else
        @$('.selector-root-container')
          .toggleClass 'expanded', true
          .toggleClass 'collapsed', false
          .toggleClass 'always-expanded', false
        #@$( '.selector-filter-input' ).focus()
      return this

    updateAvailability: ->
      viewModel = @getViewModel()
      @renderAvailability viewModel
      return this

    renderAvailability: (viewModel) ->
      @$('.selector-root-container')
        .toggleClass 'disabled', viewModel.isDisabled is true
      return this

    # updateBusyIndicator: ->
    #   viewModel = @getViewModel()
    #   console.log "busy: #{viewModel.isBusy}"

    onOverlayClick: (event) ->
      @trigger "click:outside", @model

      if @config.view.overlaySimulateClick is true
        @$ '.selector-overlay'
          .toggleClass 'expanded', false
          .toggleClass 'collapsed', true

        _.delay ->
          $element = $ document.elementFromPoint(event.clientX, event.clientY)
          #console.log "clicking at #{event.pageX}, #{event.pageY}"
          item = _.chain $element.parents()
            .filter (m) ->
              return $(m).hasClass 'selector-root-header'
            .first()
            .value()
          if item?
            $(item).click()
        , 0#@config.view.throttleTimeMilliseconds

      return this

  return
