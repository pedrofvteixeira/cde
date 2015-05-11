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

  getPageData = (queryInfo, pageSize) ->
    pageData = {}
    if queryInfo?.pageStart?
      pageData=
        page: parseInt(queryInfo.pageStart) // pageSize
    return pageData

  itemGenerator = (idx, pageData) ->
    if not _.isObject pageData
      pageData = {}
    createItems = (rows) ->
      return _.map rows, (row) ->
        itemData =
          id: row[idx.id]
          label: row[idx.label]
        if _.isFinite(idx.value) and idx.value >= 0
          itemData.value = row[idx.value]
        itemData = $.extend true, itemData, pageData
        return itemData
    return createItems

  groupGenerator =  (idx, pageData) ->
    createGroup = (rows, group) ->
      groupData =
        id: if group? then rows[0][idx.parentId] else undefined
        label: rows[0][idx.parentLabel]
        nodes: itemGenerator(idx, pageData)(rows)
      # if _.isFinite(idx.value) and idx.value >= 0
      #   groupData.value = 0#row[idx.value]
      return groupData
    return createGroup


  ###*
  # Import data from multiple sources, populate the model
  # @class Input
  # @uses TreeSelector.Logger
  # @extends BaseModel
  # @constructor
  # @params {Object} options
  ###
  DataHandlers.Input = BaseModel.extend(LoggerMixin).extend

    ID: 'TreeSelector.DataHandlers.Input'

    # defaults:
    #   hooks:
    #     postUpdate: {}

    getModel: ->
      return @get('model')


    ###*
    # Import data into the MVC model, eventually inferring the data format
    # @method updateModel
    # @param {CDAJson | Array} whatever
    # @chainable
    # @public
    ###
    updateModel: ( whatever ) ->
      if _.isArray whatever
        @_updateModelFromBidimensionalArray whatever
      else if @isCdaJson whatever
        @_updateModelFromCdaJson whatever
      else
        @_updateModelJson whatever
      model = @get 'model'
      model.set 'isBusy', false
      model.set 'isDisabled', @get('model').children() is null

      options = @get 'options'
      if options.hooks?.postUpdate
        _.each options.hooks.postUpdate, (hook) ->
          hook.call null, null, model, options

      @trigger 'postUpdate', model

      return this


    _updateModelFromCdaJson: ( json ) ->
      # Do specific stuff for data set
      options = $.extend true, {}, @get('options')
      pageData = getPageData json.queryInfo, options.query.getOption('pageSize')

      if _.chain(options.indexes).map(_.identity).max().value() <  json.metadata.length
        data = _.chain json.resultset
          .groupBy (row) -> return row[ options.indexes.parentId ]
          .map groupGenerator(options.indexes, pageData)
          .value()
      else
        data = itemGenerator(options.indexes, pageData)(json.resultset)
        if options.root?.id?
          @info "Setting root id to: " + options.root.id
          @get('model').set('id',  options.root.id)
        #data = groupGenerator(idx)('', json.resultset)

      #console?.table json.resultset
      @get('model').add data
      if json.queryInfo?.pageStart?
        numberOfItems = parseInt(json.queryInfo.totalRows)
      else
        numberOfItems = undefined

      searchPattern = options.query.getOption('searchPattern')
      if _.isEmpty(searchPattern)
        @get('model').set 'numberOfItemsAtServer', numberOfItems

      return this


    _updateModelFromJson: ( anyJsonObject ) ->
      # Do specific stuff for parameter
      # if _.isFunction @callbacks.importFromParameter
      #   @callbacks.importFromParameter (data)
      return this


    _updateModelFromBidimensionalArray: ( rows ) ->
      if rows.length > 0
        return this

      idx =
        id: 0
        label: 1
        value: undefined

      data = itemGenerator(idx)(rows)
      @get('model').add data
      return this


    isCdaJson: ( obj ) ->
      result = false
      if _.isObject obj
        if _.isArray obj.resultset
          if _.isArray obj.metadata
            result = true
      return result


    ###*
    # Matches the items against a list and marks the matches as selected
    # @method setValue
    # @param {Array} selectedItems Arrays containing the ids of the selected items
    # @chainable
    # @public
    ###
    setValue: ( selectedItems ) ->
      @get('model').setSelectedItems selectedItems
      @trigger 'setValue', selectedItems
      return this


    injectFakeData: (label, level ) ->
      generateData = (label, level) ->
        return [
          label: label
          id: "#{level}.all"
          value: Math.pow(10, level-1) + _.random(Math.pow 10, level)
          nodes: _.map _.range(Math.pow 10, level), (v) ->
            node =
              label: "Item #{level}.#{v}"
              value: _.random(100)
              id: "#{level}.#{v}"
            return node
        ]
      @get('model').add generateData label, level

   return #IIFE
