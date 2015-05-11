###*
# An intuitive Selector Component with many out-of-the-box features:
# - pluggable selection logic: single-, multi-, and limited-select
# - automatic handling of groups of options
# - searchable
# - extensible via addIns
# @class SelectorComponent
# @constructor
###
SelectorComponent = do (
  $ = $
  _ = _
  Backbone = Backbone
  Logger = Dashboards
  UnmanagedComponent = UnmanagedComponent
  TreeSelector = TreeSelector
) ->
  'use strict'
  ###
   * Über-selector: one selector to rule them all
  ###

  ###*
  # Interface Mixin for a selector
  ###
  ISelector =
    ###*
    # Gets the current selection state
    # @method getValue
    # @public
    # @for SelectorComponent
    # @return {Array} List of strings containing the IDs of the selected items,
    # in the same format as they would be written to the parameter
    ###
    getValue: ->
      return @_value

    ###*
    # Updates the selection state of the selector
    # @method setValue
    # @public
    # @for SelectorComponent
    # @param {Array} value List of strings containing the IDs of the selected items,
    # which will be written to the parameter
    # @chainable
    ###
    setValue: (value) ->
      @inputDataHandler.setValue value
      return this

    ###*
    # Implement's CDF logic for updating the state of the parameter, by
    # invoking Dashboards.processChange()
    # @method processChange
    # @public
    # @for SelectorComponent
    # @param {Array} value List of strings containing the IDs of the selected items,
    # in the same format as they would be written to the parameter
    ###
    processChange: (value) ->
      @_value = value
      @dashboard.processChange @name
      return this



  ###*
  # Interface mixin for the configuration
  ###
  IConfiguration =
    ###*
    # Default settings of the component
    # <pre>
    # <code>
    # {
    #   component: {}, // Uses TreeSelector defaults
    #   input: {
    #     defaultModel: {
    #      isDisabled: true
    #     },
    #     indexes: { // layout of the data: column indexes
    #       id: 0,
    #       label: 1,
    #       parentId: 2,
    #       parentLabel: 3,
    #       value: undefined
    #     }
    #   },
    #   output: {}
    # }
    # </code>
    # </pre>
    # @property defaults
    # @for SelectorComponent
    # @type {Object}
    ###
    defaults:
      component: {}
      input:
        defaultModel:
          isDisabled: true
        indexes:
          id: 0
          label: 1
          parentId: 2
          parentLabel: 3
          value: 4
        # root:
        #   id: 'all'
      output: {}

    ###*
    # Collate and conciliate settings from the following origins:
    # - component's {{#crossLink "SelectorComponent/defaults:property"}}{{/crossLink}}
    # - properties set by the user at design time, via the CDE interface
    # - options programmatically defined at run time
    # @method getConfiguration
    # @for SelectorComponent
    # @public
    # @return {Object} Returns a configuration object
    ###
    getConfiguration: ->
      cd = @componentDefinition
      ci = @componentInput
      co = @componentOutput
      that = this

      selectionStrategy = if cd.multiselect then 'LimitedSelect' else 'SingleSelect'
      configuration =
        input:{}
        output: {}
        component: $.extend true, {},
          TreeSelector.defaults()
          TreeSelector.Enum.selectionStrategy[selectionStrategy]
          target: @placeholder()

      $.extend true, configuration, _.result(this, 'defaults')

      _getPage = (page, searchPattern) ->
        #Logger.log "CDFSelector: Page #{page} matching '#{searchPattern}' was requested", 'debug'
        deferred = $.Deferred()

        ###
        # Handle empty datasets
        ###
        if @query.getOption('pageSize') is 0
          deferred.resolve {}
          return deferred

        callback = _.bind (data) ->
          @inputDataHandler.updateModel data
          @model.setBusy false
          deferred.resolve data
          return data
        , this

        @model.setBusy true
        try
          pattern = if _.isEmpty(searchPattern) then '' else searchPattern
          @query.setSearchPattern pattern
          switch page
            when 'previous'
              if @query.getOption('page') isnt 0
                @query.previousPage callback
            when 'next'
              @query.nextPage callback
            else
              @query.setOption 'page', page
              @query.doQuery callback
        catch error
          #@dashboard.log "error: #{JSON.stringify error}"
          deferred.reject {}
          @model.setBusy false
        return deferred

      styles = []
      if not cd.showIcons
        styles.push 'no-icons'

      ###*
      # validate pagination
      ###
      pageSize = Infinity
      if @queryDefinition.pageSize?
        if _.isFinite(@queryDefinition.pageSize) and @queryDefinition.pageSize > 0
          pageSize = @queryDefinition.pageSize


      $.extend true, configuration.component,
        pagination:
          pageSize: pageSize
          getPage: _.bind _getPage, this
        selectionStrategy:
          limit: if _.isNumber(cd.selectionLimit) then cd.selectionLimit else Infinity
        Root:
          options:
            styles: styles
            # showIcons: cd.showIcons
            alwaysExpanded: cd.alwaysExpanded
            showFilter: cd.showFilter
            useOverlay: cd.useOverlay
          strings:
            title: cd.title
        # Group:
        #   options:
        #     showIcons: cd.showIcons
        # Item:
        #   options:
        #     showIcons: cd.showIcons


      ###*
      # Localize strings, if they are defined
      ###
      i18nMap = this.dashboard.i18nSupport.map
      that = this
      _.each ['Root', 'Group', 'Item'], (level) ->
        _.each configuration.component[level].strings, (value, token, list) ->
          fullToken = "selector_#{level}_#{token}"
          #console.log fullToken
          if _.has(i18nMap, fullToken)
            list[token] = that.dashboard.i18nSupport.prop fullToken




      selectionStrategyConfig = configuration.component.selectionStrategy
      strategy = new TreeSelector.SelectionStrategies[selectionStrategyConfig.type](selectionStrategyConfig)
      configuration.component.selectionStrategy.strategy = strategy

      ###*
      # Patches
      ###
      if selectionStrategyConfig isnt 'SingleSelect'
        if cd.showButtonOnlyThis is true or cd.showButtonOnlyThis is false
          configuration.component.Root.options.showButtonOnlyThis = cd.showButtonOnlyThis



      ###*
      #  Add input/output options to configuration object
      ###
      $.extend true,
        configuration.input
        @componentInput
        query: @query

      $.extend true, configuration.output, @componentOutput

      configuration = $.extend true,
        configuration,
        @_mapAddInsToConfiguration()
        _.result(this, 'options')

      return configuration

    ###*
    # List of add-ins to be processed by the component
    # <pre>
    # <code>
    # {
    #   postUpdate:  [], // e.g. 'accordion'
    #   renderRootHeader: [],
    #   renderRootSelection: [], // e.g. ['sumSelected', 'notificationSelectionLimit']
    #   renderRootFooter: [],
    #   renderGroupHeader: [],
    #   renderGroupSelection:[],
    #   renderGroupFooter: [],
    #   renderItemSelection: [],
    #   sortGroup: [],
    #   sortItem: []
    # }
    # </pre>
    # </code>
    # @property addIns
    # @type Object
    # @public
    ###
    _mapAddInsToConfiguration: ->
      ###*
      # Traverse the list of declared addIns,
      # Get the addIns, the user-defined options, wrap this into a function
      # Create a hash map { slot: [ function($tgt, model, options) ]}
      ###
      that = this
      addInList = _.chain @addIns#$.extend(true, {}, @addIns, { sortItem: ['selectedOnTop'] })
        .map (list, slot) ->
          addIns = _.chain( list ).map (name) ->
            addInName = name.trim()
            addIn = that.getAddIn slot, addInName
            if addIn?
              addInOptions = that.getAddInOptions slot, addInName
              return  ($tgt, model, options) ->
                st =
                  model: model
                  configuration: options
                return addIn.call $tgt, st, addInOptions
            else
              return null
          .compact()
          .value()
          return [
            slot
            addIns
          ]
        .object()
        .value()

      ###*
      # Place the functions in the correct location in the configuration object
      ###
      addInHash =
        postUpdate: 'input.hooks.postUpdate'
        renderRootHeader:    'component.Root.renderers.header'
        renderRootSelection: 'component.Root.renderers.selection'
        renderRootFooter:    'component.Root.renderers.footer'
        #
        renderGroupSelection: 'component.Group.renderers.selection'
        renderItemSelection:  'component.Item.renderers.selection'
        #
        sortItem: 'component.Item.sorter'
        sortGroup: 'component.Group.sorter'
        #
        outputFormat: 'output.outputFormat'

      configuration = {}
      getOrCreateEntry = (memo, key) ->
        if memo[key]?
          return memo[key]
        else
          memo[key] = {}

      _.each addInList, ( functionList, addInSlot ) ->
        ###*
        # I just wish we could do something like
        #   configuration['compoent.Root.renderers.selection'] = foo
        ###
        if not _.isEmpty functionList
          configAddress = addInHash[addInSlot].split('.')
          parentAddress = _.initial configAddress
          childKey = _.last configAddress
          parent = _.reduce parentAddress, getOrCreateEntry, configuration
          parent[childKey] = addInList[addInSlot]

      return configuration




  Selector = UnmanagedComponent.extend(ISelector).extend(IConfiguration).extend(
    ###
    # properties (data inputs)
    queryDefinition: undefined # move this to componentInput, if possible
    parameters: []
    componentInput:
      queryParameters: undefined
      valuesArray: undefined # does
      inputParameter: undefined

    componentOutput:
      outputParameter: undefined
      preOutput: undefined
    # configuration options (view inputs)
    componentDefinition:
      addIns:
        importFromQuery: []
        importFromParameter: []
        importFromValuesArray: []
    ###
    ###*
    # Object responsible for storing the MVC model, which contains both the data and the state of the component
    # @property model
    # @public
    # @type SelectionTree
    ###
    model: undefined

    ###*
    # Object responsible for managing the MVC hierarchy of views and controllers associated with the model
    # @property manager
    # @public
    # @type Manager
    ###
    manager: undefined

    ###*
    # Object that handles writing to the MVC model
    # @property inputDataHandler
    # @public
    # @type Input
    ###
    inputDataHandler: undefined

    ###*
    # Object that handles reading from the MVC model.
    # @property outputDataHandler
    # @public
    # @type Output
    ###
    outputDataHandler: undefined


    update: ->
      # if not @isInitialized
      #   @initialize()
      #   @isInitialized = true

      that = this
      initMVC = (data) ->
        deferred = new $.Deferred()
        that.initialize()
          .then (configuration) ->
            deferred.resolve data
            return
        return deferred.promise()

      @getData()
        .then initMVC, _.bind( @onDataFail, this)
        .then _.bind( @onDataReady, this)
        #.then _.bind( @__postUpdate, this)

      return this


    close: ->
      if @manager?
        @manager.walkDown (m) ->
          m.close()
          m.remove()

      if @model?
        @model
          .stopListening()
          .off()

      @stopListening()

    ###*
    # Initialize the component by creating new instances of the main objects:
    # - model
    # - MVC manager
    # - input data handler
    # - output data handler
    #
    # @method initialize
    # @return {Promise} Returns a $.Deferred().promise() object
    ###
    initialize: ->
      ###*
      # Transform user-defined CDF settings to our own configuration object
      ###
      configuration = @getConfiguration()

      @close()
      ###*
      # Initialize our little MVC world
      ###
      @model = new TreeSelector.Models.SelectionTree(configuration.input.defaultModel)
      @manager = new TreeSelector.Controllers.Manager(
        model: @model
        configuration: configuration.component
      )
      ###*
      # Initialize the CDF interface
      ###

      @inputDataHandler = new TreeSelector.DataHandlers.Input(
        model: @model
        options: configuration.input
      )
      @outputDataHandler = new TreeSelector.DataHandlers.Output(
        model: @model
        options: configuration.output
      )
      @listenTo @outputDataHandler, 'changed', @processChange
      deferred = new $.Deferred()
      deferred.resolve configuration
      return deferred.promise()


    ###*
    # Abstract the origin of the data used to populate the component.
    # Precedence order for importing data: query -> parameter -> valuesArray
    # @method getData
    # @return {Promise} Returns promise that is fullfilled when the data is available
    ###
    getData: ->
      deferred = new $.Deferred()

      dataCallback =  _.bind( (data) ->
        deferred.resolve data
        return
      , this)

      that = this
      if not _.isEmpty @dashboard.detectQueryType(@queryDefinition)
        queryOptions =
          ajax:
            error: ->
              deferred.reject {}
              Logger.log "Query failed", 'debug'

        @triggerQuery @queryDefinition, dataCallback, queryOptions
      else
        if @componentInput.inputParameter and not _.isEmpty(@componentInput.inputParameter)
          inputParameterValue = @dashboard.getParameterValue(@componentInput.inputParameter)
          @synchronous dataCallback, inputParameterValue
        else
          @synchronous dataCallback, @componentInput.valuesArray

      return deferred.promise()


    # getSuccessHandler: (counter, success, always) ->
    #   this.base counter, success, always

    ###*
    # Launch an event equivalent to postExecution
    ###
    # __postUpdate: ->
    #   @trigger 'post:update', this

    ###*
    # @method onDataReady
    # @public
    # @chainable
    ###
    onDataReady: (data) ->
      @inputDataHandler.updateModel data
      if @parameter
        currentSelection =  @dashboard.getParameterValue @parameter
        @setValue currentSelection
      ###*
      # @event getData:success
      ###
      @trigger 'getData:success'
      return this

    ###*
    # @method onDataFail
    # @public
    # @chainable
    ###
    onDataFail: (reason) ->
      Logger.log 'Component failed to retrieve data: #{reason}', 'debug'
      @trigger 'getData:failed'
      return this


  ,
    help: ->
      "Selector component"
  )
  return Selector
