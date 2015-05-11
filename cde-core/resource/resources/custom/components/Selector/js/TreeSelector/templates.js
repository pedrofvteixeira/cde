(function(templates){
  $.extend( true, templates, {
    "Group-skeleton": [
      '<div class="selector-group-container {{className}}">',
      '',
      '<div class="selector-group-header"/>',
      '',
      '<div class="selector-group-body">',
      '<div class="selector-group-items-container">',
      '<div class="selector-group-items"></div>',
      '</div>',
      '</div>',
      '',
      '<div class="selector-group-footer">',
      '{{#showPagination}}',
      '<button class="selector-btn-more-data">More...</button>',
      '{{/showPagination}}',
      '{{{footer}}}',
      '</div>',
      '',
      '</div>',
      ''
    ].join(""),
    "Group-template": [
      '<div class="selector-group-header',
      '{{#isPartiallySelected}} some-selected{{/isPartiallySelected}}',
      '{{^isPartiallySelected}}',
      '{{#isSelected}} all-selected{{/isSelected}}',
      '{{^isSelected}} none-selected{{/isSelected}}',
      '{{/isPartiallySelected}}',
      '">',
      '',
      '{{#showButtonCollapse}}',
      '<div class="selector-collapse-icon',
      '{{#isCollapsed}} collapsed{{/isCollapsed}}',
      '{{^isCollapsed}} expanded{{/isCollapsed}}',
      '" />',
      '{{/showButtonCollapse}}',
      '',
      '<div class="selector-group-title">',
      '{{{label}}}',
      '</div>',
      '',
      '<div class="selector-controls">',
      '{{#showFilter}}',
      '<div class="selector-filter">',
      '<input type="text" class="selector-filter-input" />',
      '<div class="selector-filter-icon" />',
      '<div class="selector-filter-clear" />',
      '</div>',
      '{{/showFilter}}',
      '{{#showCommitButtons}}',
      '<div class="selector-controls-buttons">',
      '<div class="selector-controls-button">',
      '<button class="selector-btn-cancel">{{strings.btnCancel}}</button>',
      '</div>',
      '<div class="selector-controls-button">',
      '<button class="selector-btn-apply">{{strings.btnApply}}</button>',
      '</div>',
      '</div>',
      '{{/showCommitButtons}}',
      '</div>',
      '',
      '',
      '{{#allowGroupSelection}}',
      '<div class="selector-group-selection">',
      '',
      '<div class="selector-group-selection-icon',
      '{{#isPartiallySelected}} some-selected{{/isPartiallySelected}}',
      '{{^isPartiallySelected}}',
      '{{#isSelected}} all-selected{{/isSelected}}',
      '{{^isSelected}} none-selected{{/isSelected}}',
      '{{/isPartiallySelected}}',
      '" />',
      '',
      '<div class="selector-group-label">',
      '{{strings.groupSelection}}',
      '</div>',
      '',
      '',
      '</div>',
      '{{/allowGroupSelection}}',
      '{{#showValue}}',
      '<div class="selector-group-selection-value">',
      '{{{value}}}',
      '</div>',
      '{{/showValue}}',
      '',
      '',
      '</div>',
      ''
    ].join(""),
    "Item-template": [
      '<div class="selector-item-container',
      '{{#isPartiallySelected}} some-selected{{/isPartiallySelected}}',
      '{{^isPartiallySelected}}',
      '{{#isSelected}} all-selected{{/isSelected}}',
      '{{^isSelected}} none-selected{{/isSelected}}',
      '{{/isPartiallySelected}}',
      '">',
      '',
      '{{#header}}',
      '<div class="selector-item-header"> {{{header}}} </div>',
      '{{/header}}',
      '',
      '<div class="selector-item-body">',
      '<!-- <label class="selector-item-label"> -->',
      '<!-- <input type="checkbox" {{#isSelected}}checked="true"{{/isSelected}} /> -->',
      '<!-- {{{label}}} -->',
      '<!-- </label> -->',
      '{{{item}}}',
      '',
      '<div class="selector-item-selection-icon">',
      '<div />',
      '</div>',
      '',
      '{{#showButtonOnlyThis}}',
      '<span class="selector-item-only-this">',
      '{{{strings.btnOnlyThis}}}',
      '</span>',
      '{{/showButtonOnlyThis}}',
      '',
      '<div class="selector-item-label"',
      'title="{{{label}}}"',
      '>',
      '{{{label}}}',
      '</div>',
      '',
      '{{#showValue}}',
      '<div class="selector-item-value">',
      '{{{value}}}',
      '</div>',
      '{{/showValue}}',
      '</div>',
      '',
      '{{#footer}}',
      '<div class="selector-item-footer"> {{{footer}}} </div>',
      '{{/footer}}',
      '',
      '</div>',
      ''
    ].join(""),
    "Root-footer": [
      '<div class="selector-root-footer">',
      '',
      '{{#isBusy}}',
      '<div class="selector-busy" />',
      '{{/isBusy}}',
      '{{#reachedSelectionLimit}}',
      '<div class="selector-root-notification">',
      'The selection limit (',
      '<span class="selector-notification-highlight">{{selectionStrategy.limit}}</span>',
      ') for specific items has been reached.',
      '</div>',
      '{{/reachedSelectionLimit}}',
      '</div>',
      ''
    ].join(""),
    "Root-header": [
      '<div class="selector-root-header',
      '{{#isPartiallySelected}} some-selected{{/isPartiallySelected}}',
      '{{^isPartiallySelected}}',
      '{{#isSelected}} all-selected{{/isSelected}}',
      '{{^isSelected}} none-selected{{/isSelected}}',
      '{{/isPartiallySelected}}',
      '">',
      '<div class="selector-root-header-label"',
      '{{#showTooltip}}',
      'title="{{#header}}{{{header}}}{{/header}}{{^header}}{{#selectedItems}}{{{.}}}{{/selectedItems}}{{/header}}"',
      '{{/showTooltip}}',
      '>',
      '',
      '{{#isDisabled}}',
      '{{{strings.isDisabled}}}',
      '{{/isDisabled}}',
      '',
      '{{^isDisabled}}',
      '{{#showSelectedItems}}',
      '<span class="selector-root-info-selected-items">',
      '{{^noItemsSelected}}',
      '<span class="selector-root-info-selected-item"',
      'title="{{#selectedItems}}{{{.}}} {{/selectedItems}}"',
      '>',
      '{{#selectedItems}}',
      '{{{.}}}',
      '{{/selectedItems}}',
      '</span>',
      '{{/noItemsSelected}}',
      '{{#noItemsSelected}}',
      '<span class="selector-root-info-selected-item">',
      '{{{strings.noItems}}}',
      '</span>',
      '{{/noItemsSelected}}',
      '</span>',
      '{{/showSelectedItems}}',
      '',
      '',
      '{{#showNumberOfSelectedItems}}',
      '{{#allItemsSelected}}',
      '<span class="selector-root-info-selected-items">',
      '{{{strings.allItems}}}',
      '</span>',
      '{{/allItemsSelected}}',
      '',
      '{{#noItemsSelected}}',
      '<span class="selector-root-info-selected-items">',
      '{{{strings.noItems}}}',
      '</span>',
      '{{/noItemsSelected}}',
      '',
      '{{^allItemsSelected}}',
      '{{^noItemsSelected}}',
      '<span class="selector-root-info-selected-items">',
      '<span class="selector-root-info-number-selected-items">',
      '{{numberOfSelectedItems}}',
      '</span>',
      '<span class="selector-root-info-number-items">',
      '&nbsp;/&nbsp;{{numberOfItems}}',
      '</span>',
      '</span>',
      '{{/noItemsSelected}}',
      '{{/allItemsSelected}}',
      '{{/showNumberOfSelectedItems}}',
      '{{/isDisabled}}',
      '</div>',
      '<div class="selector-collapse-icon',
      '{{^isDisabled}}',
      '{{^alwaysExpanded}}',
      '{{#isCollapsed}} collapsed{{/isCollapsed}}',
      '{{^isCollapsed}} expanded {{/isCollapsed}}',
      '{{/alwaysExpanded}}',
      '{{#alwaysExpanded}} always-expanded{{/alwaysExpanded}}',
      '{{/isDisabled}}',
      '',
      '{{#isDisabled}} disabled{{/isDisabled}}',
      '',
      '" />',
      '</div>',
      ''
    ].join(""),
    "Root-overlay": [
      '{{#useOverlay}}',
      '<div class="selector-overlay',
      '{{^alwaysExpanded}}',
      '{{#isCollapsed}} collapsed{{/isCollapsed}}',
      '{{^isCollapsed}} expanded {{/isCollapsed}}',
      '{{/alwaysExpanded}}',
      '{{#alwaysExpanded}} always-expanded{{/alwaysExpanded}}',
      '" />',
      '{{/useOverlay}}',
      ''
    ].join(""),
    "Root-skeleton": [
      '<div class="selector-title">{{{strings.title}}}</div>',
      '<div class="selector-root-container',
      '{{#className}} {{className}}{{/className}}',
      '{{#styles}} {{.}} {{/styles}}',
      '{{#isDisabled}} disabled{{/isDisabled}}',
      '">',
      '{{#useOverlay}}',
      '<div class="selector-overlay',
      '{{^alwaysExpanded}}',
      '{{#isCollapsed}} collapsed{{/isCollapsed}}',
      '{{^isCollapsed}} expanded {{/isCollapsed}}',
      '{{/alwaysExpanded}}',
      '{{#alwaysExpanded}} always-expanded{{/alwaysExpanded}}',
      '" />',
      '{{/useOverlay}}',
      '<div class="selector-root-header',
      '{{#isPartiallySelected}} some-selected{{/isPartiallySelected}}',
      '{{^isPartiallySelected}}',
      '{{#isSelected}} all-selected{{/isSelected}}',
      '{{^isSelected}} none-selected{{/isSelected}}',
      '{{/isPartiallySelected}}',
      '',
      '{{^alwaysExpanded}}',
      '{{#isCollapsed}} collapsed{{/isCollapsed}}',
      '{{^isCollapsed}} expanded {{/isCollapsed}}',
      '{{/alwaysExpanded}}',
      '{{#alwaysExpanded}} always-expanded{{/alwaysExpanded}}',
      '">',
      '<div class="selector-root-header-label">',
      '{{{header}}}',
      '</div>',
      '<div class="selector-root-collapse-icon" />',
      '</div>',
      '',
      '<div class="selector-root-body" >',
      '<div class="selector-root-control" />',
      '<div class="selector-root-items-container">',
      '<div class="selector-root-items" />',
      '</div>',
      '<div class="selector-root-footer"> {{{footer}}} </div>',
      '</div>',
      '',
      '</div>',
      ''
    ].join(""),
    "Root-template": [
      '<div class="selector-root-control',
      '{{#isPartiallySelected}} some-selected{{/isPartiallySelected}}',
      '{{^isPartiallySelected}}',
      '{{#isSelected}} all-selected{{/isSelected}}',
      '{{^isSelected}} none-selected{{/isSelected}}',
      '{{/isPartiallySelected}}',
      '',
      '{{^alwaysExpanded}}',
      '{{#isCollapsed}} collapsed{{/isCollapsed}}',
      '{{^isCollapsed}} expanded {{/isCollapsed}}',
      '{{/alwaysExpanded}}',
      '{{#alwaysExpanded}} always-expanded{{/alwaysExpanded}}',
      '">',
      '<div class="selector-controls">',
      '',
      '{{#showCommitButtons}}',
      '<div class="selector-control-buttons">',
      '<div class="selector-control-button">',
      '<button class="selector-btn-cancel',
      '{{#hasChanged}} dirty{{/hasChanged}}',
      '{{^hasChanged}} pristine{{/hasChanged}}',
      '"',
      '>',
      '{{{strings.btnCancel}}}',
      '</button>',
      '</div>',
      '<div class="selector-control-button">',
      '<button class="selector-btn-apply',
      '{{#hasChanged}} dirty{{/hasChanged}}',
      '{{^hasChanged}} pristine{{/hasChanged}}',
      '"',
      '{{^hasChanged}} disabled="disabled"{{/hasChanged}}',
      '>',
      '{{{strings.btnApply}}}',
      '</button>',
      '</div>',
      '</div>',
      '{{/showCommitButtons}}',
      '',
      '{{#showFilter}}',
      '<div class="selector-filter">',
      '<input type="text" class="selector-filter-input" />',
      '<div class="selector-filter-icon" />',
      '<div class="selector-filter-clear" />',
      '</div>',
      '{{/showFilter}}',
      '',
      '</div>',
      '',
      '',
      '',
      '<div class="selector-root-selection">',
      '',
      '{{#showGroupSelection}}',
      '<div class="selector-root-selection-icon',
      '{{#isPartiallySelected}} some-selected{{/isPartiallySelected}}',
      '{{^isPartiallySelected}}',
      '{{#isSelected}} all-selected{{/isSelected}}',
      '{{^isSelected}} none-selected{{/isSelected}}',
      '{{/isPartiallySelected}}',
      '" />',
      '<div class="selector-root-selection-label">',
      '{{{label}}}',
      '</div>',
      '',
      '{{#showValue}}',
      '<div class="selector-root-selection-value">',
      '{{{value}}}',
      '</div>',
      '{{/showValue}}',
      '',
      '{{/showGroupSelection}}',
      '',
      '{{#showSelectedItems0}}',
      '<div class="selector-selected-items">',
      '{{#selectedItems}}',
      '<span class="selector-selected-item">{{.}}</span>',
      '{{/selectedItems}}',
      '</div>',
      '{{/showSelectedItems0}}',
      '',
      '</div>',
      '',
      '',
      '</div>',
      ''
    ].join(""),
    undefined: "No template" 
  });
})(TreeSelector.templates);
