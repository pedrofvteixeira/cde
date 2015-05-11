'use strict'

do (
  _ = _
  TreeModel = Backbone.TreeModel
  BaseBone = BaseBone
  Logger = TreeSelector.Logger
  Models = TreeSelector.Models
) ->
  ###*
  # @module TreeSelector
  # @submodule Models
  # @class Tree
  # @constructor
  # @extends Backbone.TreeModel
  # @uses Logger
  # @uses BaseBone
  ###
  Models.Tree = BaseBone.extendWithEvents(TreeModel).extend(Logger).extend

    url: ''
    children: ->
      @nodes.apply this, arguments

    # validate: (attrs, options) ->

    # sync: (action, obj)->
    #   @log "Please #{action} item #{obj.get('label')}"

    parse: (response, options) ->
      response


    # walkUp: ( itemCallback, combineCallback, alwaysCallback ) ->
    #   this

    ###*
    # walk down the tree and do stuff:
    # 1. if the node has no children, call itemCallback and get the result
    # 2. if the node has children, run child.walk for every child and combine the array of results with combineCallback
     *
     *
    #     function combineCallback(model, array){
    #         return _.all(array);
    #     }
     *
    # @method walkDown
    # @param {function} itemCallBack
    # @param {function} combineCallBack
    # @param {function} alwaysCallBack
    ###
    walkDown: ( itemCallback, combineCallback, alwaysCallback ) ->
      if not combineCallback
        combineCallback = (x) -> x

      if @children()
        result = combineCallback @children().map (child) ->
          return child.walkDown( itemCallback, combineCallback, alwaysCallback)
      else
        result = itemCallback this

      if _.isFunction alwaysCallback
        result = alwaysCallback this, result

      return result


    ###*
    # Returns self and descendants as a flat list
    # @method flatten
    # @return { wrappedList } Returns a list wrapped by _.chain()
    ###
    flatten: ->
      list = [ this ]
      if @children()
        @children().each (node) ->
          node.flatten().each (el) ->
            list.push el
      return _.chain list
