'use strict'
###*
# @module TreeSelector
# @submodule Controllers
###
do (
  _ = _
  BaseBone = BaseBone
  BaseView = BaseView
  LoggerMixin = TreeSelector.Logger
  Controllers = TreeSelector.Controllers
) ->
  'use strict'
  ###*
  # General-purpose controller
  # @class RootCtrl
  # @constructor
  # @uses TreeSelector.Logger
  # @extends Backbone.View
  ###
  Controllers.RootCtrl = BaseBone.extendWithEvents(Base).extend(LoggerMixin).extend
    constructor: (args) ->
      $.extend this, _.pick args, [
        'model'
        'view'
        'configuration'
      ]
      if @view
        @bindToView @view
      return this

    # bindModel: (model) ->
    #   return this

    bindToView: (view) ->
      bindings =
        'selected': @onSelection
        'toggleCollapse': @onToggleCollapse
        'control:only-this': @onOnlyThis
        'control:apply': @onApply
        'control:cancel': @onCancel
        'click:outside': @onClickOutside

      that = this
      _.each bindings, (callback, event) ->
        that.listenTo view, event, callback

      return this

    ###*
    # Event handling
    ###

    ###*
    # Acts upon the model whenever the user selected something.
    # Delegates work to the current selection strategy
    # @method onSelection
    # @chainable
    ###
    onSelection: (model) ->
      @configuration.selectionStrategy.strategy.changeSelection model
      return this


    ###*
    # Informs the model that the user chose to commit the current selection
    # Delegates work to the current selection strategy
    # @method onApply
    # @chainable
    ###
    onApply: (model) ->
      @configuration.selectionStrategy.strategy.applySelection model
      return this


    ###*
    # Informs the model that the user chose to revert to the last saved selection
    # Delegates work to the current selection strategy
    # @method onCancel
    # @chainable
    ###
    onCancel: (model) ->
      model.restoreSelectedItems()
      model.root().set 'isCollapsed', true
      return this


    onToggleCollapse: (model) ->
      @debug "Setting isCollapsed"
      if model.get('isDisabled') is true
        newState = true
      else
        oldState = model.get('isCollapsed')
        newState = not oldState
      model.set 'isCollapsed', newState
      return this


    onClickOutside: (model) ->
      model.set 'isCollapsed', true
      return this


    onOnlyThis: (model) ->
      @debug "Setting Only This"
      @model.root().setSelection TreeSelector.Enum.select.NONE
      @configuration.selectionStrategy.strategy.setSelection TreeSelector.Enum.select.ALL, model
      #@trigger 'post:selection', model
      return this
