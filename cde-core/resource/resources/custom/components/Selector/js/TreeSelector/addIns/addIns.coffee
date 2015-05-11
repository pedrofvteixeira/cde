'use strict'

do (
  Dashboards = Dashboards
  AddIn = AddIn
  Renderers = TreeSelector.Extensions.Renderers
) ->
  'use strict'
  myAddIn = new AddIn
    name: 'notificationSelectionLimit'
    label: 'Notification that the selection limit has been reached'
    help: 'Acts on the footer of the Root view'
    defaults:
      hook: 'footer'
    implementation: ($tgt, st, options) ->
      #Dashboards.log "Running addIn"
      Renderers.notificationSelectionLimit.call this, $tgt, st.model, st.configuration

  Dashboards.registerAddIn 'SelectorComponent', 'renderRootSelection', myAddIn
  return


do (
  Dashboards = Dashboards
  AddIn = AddIn
  Renderers = TreeSelector.Extensions.Renderers
) ->
  'use strict'
  myAddIn = new AddIn
    name: 'sumSelected'
    label: 'Sum the values of the selected items'
    implementation: ($tgt, st, options) ->
      Renderers.sumSelected.call this, $tgt, st.model, st.configuration

  Dashboards.registerAddIn 'SelectorComponent', 'renderRootSelection', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'renderGroupSelection', myAddIn
  return


do (
  Dashboards = Dashboards
  AddIn = AddIn
) ->
  'use strict'
  myAddIn = new AddIn
    name: 'randomColor'
    label: 'Programmatically sets a random color'
    defaults:
      selector: '.selector-item-body'
    implementation: ($tgt, model, options) ->
      #Dashboards.log "applying randomBorder"
      $tgt
        .find options.selector
        .css
          color: "rgb(#{_.random(255)},#{_.random(255)},#{_.random(255)})"

  Dashboards.registerAddIn 'SelectorComponent', 'renderItemSelection', myAddIn
  return



do (
  Dashboards = Dashboards
  AddIn = AddIn
  Sorters = TreeSelector.Extensions.Sorters
) ->
  'use strict'
  ###*
  # Sorts items, by keeping the selected items on top
  ###
  myAddIn = new AddIn
    name: 'selectedOnTop'
    label: 'Keep selected items on top '
    implementation: ($tgt, st, options) ->
      #return Sorters.selectedOnTop.call this, st.model
      #console?.log? "Selected on top"
      result = if st.model.getSelection() then 'A' else 'Z'
      result += st.model.index()
      return result

  Dashboards.registerAddIn 'SelectorComponent', 'sortItem', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'sortGroup', myAddIn
  return



do (
  Dashboards = Dashboards
  AddIn = AddIn
  Sorters = TreeSelector.Extensions.Sorters
) ->
  'use strict'
  ###*
  # Sorts items, by keeping the insertion order
  ###
  myAddIn = new AddIn
    name: 'insertionOrder'
    label: 'Keep insertion order'
    implementation: ($tgt, st, options) ->
      result = st.model.index()
      return result

  Dashboards.registerAddIn 'SelectorComponent', 'sortItem', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'sortGroup', myAddIn
  return



do (
  Dashboards = Dashboards
  AddIn = AddIn
) ->
  'use strict'
  ###*
  # Sorts items/groups by label
  ###
  myAddIn = new AddIn
    name: 'sortByLabel'
    label: 'Sort items by label, alphabetically'
    defaults:
      ascending: true
    implementation: ($tgt, st, options) ->
      result = st.model.get('label')
      #console.log "sort by label"
      return result
      if options.ascending
        return result
      else
        zCode = 'z'.codePointAt(0)
        return _.chain(result)
          .map (c) ->
            return zCode - c.codePointAt(0)
          .join(' ')
          .value()



  Dashboards.registerAddIn 'SelectorComponent', 'sortItem', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'sortGroup', myAddIn
  return



do (
  Dashboards = Dashboards
  AddIn = AddIn
) ->
  'use strict'
  ###*
  # Sorts items/groups by value
  ###
  myAddIn = new AddIn
    name: 'sortByValue'
    label: 'Sort items by value'
    defaults:
      ascending: false
    implementation: ($tgt, st, options) ->
      result = st.model.get('value')
      #console.log "sort by value #{result} : #{typeof result}"
      if options.ascending
        return result
      else
        return -1 * result;



  Dashboards.registerAddIn 'SelectorComponent', 'sortItem', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'sortGroup', myAddIn
  return




do (
  Dashboards = Dashboards
  Mustache = Mustache
  AddIn = AddIn
) ->
  'use strict'
  ###*
  # Sums the values of all the descendants
  ###
  myAddIn = new AddIn
    name: 'sumValues'
    label: 'Sums the values of the selected items'
    defaults:
      formatValue: (total) -> return Mustache.render '{{total}}', {total: total}
    implementation: ($tgt, st, options) ->
      total = st.model.flatten()
        .filter (m) -> return not m.children()?
        .filter (m) -> return m.getSelection() is true
        .reduce ( (memo, m) -> return memo + m.get('value') ), 0
        .value()
      selector = if st.model.isRoot() then '.selector-root-selection-value' else '.selector-group-selection-value'
      if _.isFinite(total)
        html = options.formatValue total
      else
        html = ''
      $tgt
        .find(selector + ':eq(0)')
        .html html

  Dashboards.registerAddIn 'SelectorComponent', 'renderRootSelection', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'renderGroupSelection', myAddIn
  return


do (
  Dashboards = Dashboards
  Mustache = Mustache
  AddIn = AddIn
) ->
  'use strict'
  ###*
  # Renders a Mustache template
  ###
  myAddIn = new AddIn
    name: 'template'
    label: 'Mustache template'
    defaults:
      template: '{{label}}'
      selector: ''
      postRender: undefined
    implementation: ($tgt, st, options) ->
      if not _.isEmpty(options.template)
        html = Mustache.render options.template, st.model.toJSON()
        $el = $tgt
        if not _.isEmpty(options.selector)
          $el = $tgt.find(options.selector + ':eq(0)')
        $el.html html
        if _.isFunction options.postRender
          options.postRender.call this, $tgt, st, options

  Dashboards.registerAddIn 'SelectorComponent', 'renderRootHeader', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'renderRootFooter', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'renderRootSelection', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'renderGroupSelection', myAddIn
  Dashboards.registerAddIn 'SelectorComponent', 'renderItemSelection', myAddIn
  return




do (
  Dashboards = Dashboards
  AddIn = AddIn
) ->
  'use strict'
  ###*
  # Emulate accordion behaviour on a group of selectors
  #
  # When the user expands a selector, a global event on the "Dashboards" object is issued.
  # The selectors configured to use this addIn will listen to the event and
  # close themselves accordingly
  ###
  myAddIn = new AddIn
    name: 'accordion'
    label: 'Makes all selectors behave as an accordion'
    defaults:
      group: 'filters'
    implementation: ($tgt, st, options) ->
      st.model.on 'change:isCollapsed', (model, newState) ->
        if newState is false
          #console.log "implementation of addIn accordion #{model.cid}"
          Dashboards.trigger 'selectors:close', model, options

      st.model.listenTo Dashboards, 'selectors:close', (model, opts) ->
          #console.log "Dashboards.on selectors:close"
          #console.log "Dashboards: addIn accordion #{st.model.cid} : #{model.cid}"
          #return
          if opts.group is options.group
            if model isnt st.model
              if st.model.get('isDisabled') is false
                st.model.set 'isCollapsed', true
      return

  Dashboards.registerAddIn 'SelectorComponent', 'postUpdate', myAddIn
  return
