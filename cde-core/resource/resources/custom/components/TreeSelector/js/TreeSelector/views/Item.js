'use strict';

/**
 * @module TreeSelector
 * @submodule Views
 */
(function(Views, Templates) {
  'use strict';

  /**
   * View for items
   * @class Item
   * @constructor
   * @extends AbstractView
   */
  return Views.Item = Views.AbstractView.extend({
    type: 'Item',
    ID: 'TreeSelector.Views.Root',
    template: {
      selection: Templates['Item-template'],
      skeleton: Templates['Item-template']
    },
    events: {
      'mouseover .selector-item-body': 'onMouseOver',
      'mouseout  .selector-item-body': 'onMouseOut',
      'click     .selector-item-body': 'onSelection',
      'click     .selector-item-only-this': 'onClickOnlyThis'
    },
    bindToModel: function(model) {
      this.base(model);
      this.onChange(model, 'isSelected', this.updateSelection);
      return this.onChange(model, 'isVisible', this.updateVisibility);
    },
    onClickOnlyThis: function(event) {
      event.stopPropagation();
      return this.trigger('control:only-this', this.model);
    }
  });
})(TreeSelector.Views, TreeSelector.templates);
