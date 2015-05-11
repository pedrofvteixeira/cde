'use strict'
App = {}

App.init = ->
  'use strict'
  @dataCDA0 =
    metadata: [
      colIndex: 0
      colName: 'id'
      colType: 'string'
    ,
      colIndex: 1
      colName: 'value'
      colType: 'string'
    ]
    resultset: [
      [ 'a', '0 A']
      [ 'b', '0 B']
    ]

  @dataCDA1 =
    metadata: [
      colIndex: 0
      colName: 'id'
      colType: 'string'
    ,
      colIndex: 1
      colName: 'value'
      colType: 'string'
    ,
      colIndex: 2
      colName: 'groupId'
      colType: 'string'
    ,
      colIndex: 3
      colName: 'groupLabel'
      colType: 'string'

    ]
    resultset: [
      [ 'a', '1 A', 'vowels.all', 'Vowels']
      [ 'b', '1 B', 'consonants.all', 'Consonants']
      [ 'e', '1 E', 'vowels.all', 'Vowels']

    ]


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

  ###*
  # Build composite model
  ###

  @model = new TreeSelector.Models.SelectionTree
    label: 'Root Level'
    id: 'root'

  ###*
  # Build composite view
  ###

  selectorLogic = 'SingleSelect'
  selectorLogic = 'MultiSelect'

  configuration = {}
  configuration.component = $.extend true, {},
      TreeSelector.defaults()
      TreeSelector.Enum.logic[selectorLogic],

  configuration = $.extend true, configuration,
    component:
      target: $('#selector1')
      pagination:
        getPage: (page) ->
          id = page * _.uniqueId()
          items = _.map _.range(10), (v) ->
            item =
              label: "Item #{id}.#{v}"
              value: id*100000 + v

          deferred = $.Deferred()
          deferred.resolve items
          return deferred#.promise()
      # Root:
      #   options:
      #     showFilter: true
      #     showCommitButtons: true
      #     showGroupSelection: true
      #     showSelectedItems: false
      #     showValue: true

      #   templates:
      #     skeleton: ""
      #     selection: ""
      #   renderers:
      #     header: null
      #     footer: TreeSelector.Extensions.Renderers.rootFooter
      #     selection: TreeSelector.Extensions.Renderers.sumSelected
      #   sorter: TreeSelector.Extensions.Sorters.sameOrder
      Group:
        options:
          showValue: true
        renderers:
          selection:  TreeSelector.Extensions.Renderers.sumSelected
        # sorter: TreeSelector.Extensions.Sorters.sortAlphabetically

      Item:
        options:
          showValue: true
          showButtonOnlyThis: true
        #templates:
        #   skeleton: ""
        #   selection: "fuck"
        #renderers:
        #   selection: TreeSelector.Renderers.Item
        sorter: TreeSelector.Extensions.Sorters.sortAlphabetically

  renderers =
    'MultiSelect':   TreeSelector.Extensions.Renderers.RootHeaderMultiSelect
    'LimitedSelect': TreeSelector.Extensions.Renderers.RootHeaderMultiSelect
    'SingleSelect':  TreeSelector.Extensions.Renderers.RootHeaderSingleSelect
  #configuration.Root.renderers.header = renderers[configuration.Root.options.logic.type]

  @logic = new TreeSelector.Logic[configuration.component.logic.type](configuration.component.logic)
  configuration.component.logic.manager = @logic
  @configuration = configuration

  @input = new TreeSelector.DataHandlers.Input
    model: @model
    options:
      inputValueParameter: 'xpto'

  # @view = new TreeSelector.Views.Root
  #   model: @model
  #   configuration: configuration
  #   target: $('#selector1')

  # @controller = new TreeSelector.Controllers.RootCtrl
  #   model: @model
  #   view: @view
  #   configuration: configuration

  @manager = new TreeSelector.Controllers.Manager
    model: @model
    # view: @view
    # controller: @controller
    configuration: configuration.component

  outputDataHandlerOptions =
    outputParameter: 'xpto'
    preChange: _.noop
    postChange: _.noop
    trigger: ['selection', 'apply'][1]

  @output = new TreeSelector.DataHandlers.Output
    model: @model
    #configuration: configuration
    options: outputDataHandlerOptions

  ###*
  # Update the model with new data
  ###
  #@model.add generateData "Small Group", 1
  @model.add generateData "Medium Group", 2
  #@model.add generateData "Large Group", 3
  #@model.add generateData "Huge Group", 4
  @input.setValue [ '1.' + _.random(10)]

$ ->
  'use strict'
  App.init()
  window.App = App
