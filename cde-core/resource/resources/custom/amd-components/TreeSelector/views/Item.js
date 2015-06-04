
/**
 * @module TreeSelector
 * @submodule Views
 */

define([
    './Abstract'],
    function( TreeSelector ) {

  /**
   * View for items
   * @class Item
   * @constructor
   * @extends AbstractView
   */
  TreeSelector.Views.Item = TreeSelector.Views.AbstractView.extend({
    type: 'Item',
    ID: 'TreeSelector.Views.Root',
    template: {
      selection: TreeSelector.templates['Item-template'],
      skeleton: TreeSelector.templates['Item-template']
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

  return TreeSelector;
});
