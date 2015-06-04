'use strict';

/**
 * @module TreeSelector
 * @submodule Views
 */
(function(Views, Templates) {
  'use strict';

  /**
   * View for groups of items
   * @class Group
   * @constructor
   * @extends AbstractView
   */
  return Views.Group = Views.AbstractView.extend({
    type: 'Group',
    ID: 'TreeSelector.Views.Group',
    template: {
      skeleton: Templates['Group-skeleton'],
      selection: Templates['Group-template']
    },
    events: {
      'change    .selector-filter:eq(0)': 'onFilterChange',
      'keyup     .selector-filter:eq(0)': 'onFilterChange',
      'click     .selector-filter-clear:eq(0)': 'onFilterClear',
      'click     .selector-group-selection': 'onSelection',
      'click     .selector-collapse-icon:eq(0)': 'onToggleCollapse',
      'mouseover .selector-group-container': 'onMouseOver',
      'mouseout  .selector-group-container': 'onMouseOut'
    },
    bindToModel: function(model) {
      this.base(model);
      this.onChange(model, 'isSelected numberOfSelectedItems numberOfItems', this.updateSelection);
      return this.onChange(model, 'isCollapsed', this.updateCollapse);
    },
    updateCollapse: function() {
      var viewModel;
      viewModel = this.getViewModel();
      return this.renderCollapse(viewModel);
    },
    renderCollapse: function(viewModel) {
      var collapsable;
      this.renderSelection(viewModel);
      collapsable = ['.selector-group-body', '.selector-group-footer'].join(', ');
      if (viewModel.isCollapsed) {
        return this.$(collapsable).hide();
      } else {
        return this.$(collapsable).show();
      }
    }
  });
})(TreeSelector.Views, TreeSelector.templates);
