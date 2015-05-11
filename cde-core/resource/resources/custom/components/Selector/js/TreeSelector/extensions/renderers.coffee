do (
  $ = $
  Mustache = Mustache
  Extensions = TreeSelector.Extensions
) ->
  'use strict'

  $.extend true, Extensions.Renderers,
    group: ($tgt, model, configuration) ->
      viewModel = model.toJSON()
      header = Mustache.render "{{label}}", viewModel
      footer = Mustache.render "<a href=\"http://www.google.com\">More about {{label}}</a>", viewModel
      $tgt
        .find '.selector-group-title'
        .html header
      $tgt
        .find '.selector-group-footer'
        .html footer
      $tgt
        .css
          border: "1px solid rgb(#{_.random(255)},#{_.random(255)},#{_.random(255)})"


    sumSelected: ($tgt, model, configuration) ->
      total = model.flatten()
        .filter (m) -> return not m.children()?
        .filter (m) -> return m.getSelection() is true
        .reduce ( (memo, m) -> return memo + m.get('value') ), 0
        .value()
      selector = if model.isRoot() then '.selector-root-selection-value' else '.selector-group-selection-value'
      $tgt
        .find(selector + ':eq(0)')
        .html if total is 0 then '' else total

    Item: ($tgt, model, configuration) ->
      blocks =
        item: "<span>#{viewModel.label}</span> <span style='float:right;'>comem</>"
      $tgt.find('.selector-item-body').html(blocks.item)


    rootHeaderSingleSelect: ($tgt, model, configuration) ->
      #viewModel = model.toJSON()
      #header = Mustache.render "{{label}}", viewModel
      header = model.getSelectedItems()[0] or "None"
      $tgt
        .find '.selector-root-header-label'
        .html header
        .attr 'title', header


    rootHeaderMultiSelect:  ($tgt, model, configuration) ->
      viewModel = model.toJSON()
      header = Mustache.render( """
        <span class="selector-root-info-number-selected-items">
          {{numberOfSelectedItems}}
        </span>
        <span class="selector-root-info-number-items">
          of {{numberOfItems}}
        </span>
      """, viewModel )

      console?.log "injecting content on header"
      $tgt
        .find '.selector-root-header-label'
        .html header
        .attr 'title', Mustache.render "{{numberOfSelectedItems}}/{{numberOfItems}}", viewModel

      $tgt
        .find '.selector-root-header-label'
        .mouseover (event) ->
          console?.log  "hovering #{viewModel.label}"

    notificationSelectionLimit:  ($tgt, model, configuration) ->
      viewModel = $.extend true, model.toJSON(), configuration
      footer = Mustache.render( """
        {{#reachedSelectionLimit}}
        <div class="selector-root-notification">
          <div class="selector-root-notification-icon" />
          <div class="selector-root-notification-text">
            The selection limit
            (<span class="selector-notification-highlight">{{Root.options.selectionStrategy.limit}}</span>)
            for specific items has been reached.
          </div>
        </div>
        {{/reachedSelectionLimit}}
      """, viewModel)

      $tgt
        .find '.selector-root-footer'
        .html footer

  return #IIFE
