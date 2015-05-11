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
  # View for items
  # @class Item
  # @constructor
  # @extends AbstractView
  ###
  Views.Item = Views.AbstractView.extend
    type: 'Item'
    ID: 'TreeSelector.Views.Root'

    template:
      selection: Templates['Item-template']
      skeleton: Templates['Item-template']

    events:
      'mouseover .selector-item-body' : 'onMouseOver'
      'mouseout  .selector-item-body' : 'onMouseOut'
      'click     .selector-item-body' : 'onSelection'
      'click     .selector-item-only-this': 'onClickOnlyThis'


    bindToModel: (model) ->
      this.base model
      @onChange model, 'isSelected',  @updateSelection
      @onChange model, 'isVisible',  @updateVisibility


    onClickOnlyThis: (event) ->
      event.stopPropagation()
      @trigger 'control:only-this', @model
