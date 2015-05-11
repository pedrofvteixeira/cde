'use strict'
###*
# @module TreeSelector
# @submodule Views
###
do (
  Views = TreeSelector.Views
  Templates = TreeSelector.templates
) ->
  'use strict'

  ###*
  # View for groups of items
  # @class Group
  # @constructor
  # @extends AbstractView
  ###
  Views.Group = Views.AbstractView.extend
    type: 'Group'
    ID: 'TreeSelector.Views.Group'

    template:
      skeleton: Templates['Group-skeleton']
      selection: Templates['Group-template']

    events:
      'change    .selector-filter:eq(0)': 'onFilterChange'
      'keyup     .selector-filter:eq(0)': 'onFilterChange'
      'click     .selector-filter-clear:eq(0)': 'onFilterClear'
      #'change    .selector-select-all-none:eq(0)' : 'onSelection'
      #'click     .selector-group-selection-icon' : 'onSelection'
      'click     .selector-group-selection' : 'onSelection'
      'click     .selector-collapse-icon:eq(0)' : 'onToggleCollapse'
      'mouseover .selector-group-container': 'onMouseOver'
      'mouseout  .selector-group-container': 'onMouseOut'


    bindToModel: (model) ->
      this.base model
      @onChange model, 'isSelected numberOfSelectedItems numberOfItems', @updateSelection
      @onChange model, 'isCollapsed', @updateCollapse


    updateCollapse: ->
      viewModel = @getViewModel()
      @renderCollapse viewModel


    renderCollapse: (viewModel) ->
      #@debug "handling collapse #{model.get('label')}"
      #@debug "Rendering header of item #{@model.get('label')} at count #{TreeSelector.count}"
      #@$('.selector-root-header').replaceWith Mustache.render @template.header, viewModel
      #TreeSelector.count++
      @renderSelection viewModel
      collapsable = [
        '.selector-group-body'
        '.selector-group-footer'
      ].join(', ')
      if viewModel.isCollapsed
        @$(collapsable).hide()
      else
        @$(collapsable).show()
