'use strict'
do (
  TreeSelector = TreeSelector
) ->
  TreeSelector.defaults = ->
    ###*
    # Default settings
    # @module TreeSelect
    # @submodule defaults
    # @main
    ###
    privateDefaults =
      logLevel: 1
      pagination:
        throttleTimeMilliseconds: 500
      Root:
        renderers: undefined
        sorter: undefined
        view:
          styles: []
          throttleTimeMilliseconds: 10
          templates: {}
          slots:
            selection: '.selector-root-control'
            header: '.selector-root-header'
            footer: '.selector-root-footer'
            children: '.selector-root-items'
            overlay: '.selector-overlay'
          childConfig:
            withChildrenPrototype: 'Group'
            withoutChildrenPrototype: 'Item'
            className: 'selector-root-child'
            appendTo: '.selector-root-items'
          overlaySimulateClick: true
      Group:
        renderers: undefined
        sorter: undefined
        view:
          throttleTimeMilliseconds: 10
          templates: {}
          slots:
            selection: '.selector-group-header:eq(0)'
            children: '.selector-group-items'
          childConfig:
            withChildrenPrototype: 'Group'
            withoutChildrenPrototype: 'Item'
            className: 'selector-group-child'
      Item:
        renderers: undefined
        sorter: undefined
        view:
          styles: []
          throttleTimeMilliseconds: 10
          templates: {}
          slots:
            selection: '.selector-item-container'

    defaults = $.extend true, {}, privateDefaults,
      ###*
      # @property pagination
      # @type Object
      # @for defaults
      ###
      pagination:
        pageSize: Infinity
      search:
        serverSide: false # set this to true if your datasource supports serverSide searching
      selectionStrategy:
        type: 'LimitedSelect'
        limit: 500
      ###*
      # Configuration of the Root
      # @property Root
      # @type Object
      # @for defaults
      ###
      Root:
        options:
          className: 'multi-select'
          styles: undefined
          showCommitButtons: true
          showFilter: false
          # showPagination: false
          showGroupSelection: true
          showButtonOnlyThis: false
          showSelectedItems: false
          showNumberOfSelectedItems: true
          showValue: false
          showIcons: true
          scrollThreshold: 12
          isResizable: true
          useOverlay: true
        strings:
            isDisabled: 'Unavailable'
            allItems: 'All'
            noItems: 'None'
            groupSelection: 'All'
            btnApply: 'Apply'
            btnCancel: 'Cancel'
        view:
          scrollbar:
            engine: 'mCustomScrollbar'
            options:
              theme: 'dark'
              alwaysTriggerOffsets: false
              onTotalScrollOffset: 100


      ###*
      # Configuration of the Group
      # @property Group
      # @type Object
      ###
      Group:
        options:
          showFilter: false
          showCommitButtons: false
          # showPagination: false
          showGroupSelection: false
          showButtonOnlyThis: false
          showButtonCollapse: false
          showValue: false
          showIcons: true
          scrollThreshold: Infinity
          isResizable: false
        strings:
            allItems: 'All'
            noItems: 'None'
            groupSelection: 'All'
            btnApply: 'Apply'
            btnCancel: 'Cancel'

      ###*
      # Configuration of the Item
      # @property Item
      # @type Object
      ###
      Item:
        options:
          showButtonOnlyThis: false
          showValue: false
          showIcons: true
        strings:
            btnOnlyThis: 'Only'
