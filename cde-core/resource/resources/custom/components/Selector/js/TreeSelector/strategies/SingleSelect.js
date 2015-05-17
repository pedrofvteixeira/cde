'use strict';
(function(SelectionStrategies) {
  'use strict';

  /**
   * @module TreeSelector
   * @submodule SelectionStrategies
   */

  /**
   * Single Selection
   *  - only one item can be selected at any time
   * @class SingleSelect
   * @extends AbstractSelect
   * @constructor
   */
  return SelectionStrategies.SingleSelect = SelectionStrategies.AbstractSelect.extend({
    ID: 'TreeSelector.SelectionStrategies.SingleSelect',
    setSelection: function(newState, model) {
      if (model.children()) {
        return;
      }
      if (this.isLogicGlobal === true) {
        model.root().setSelection(TreeSelector.Enum.select.NONE);
      } else if (model.getSelection() !== TreeSelector.Enum.select.ALL) {
        if (model.parent()) {
          model.parent().setSelection(TreeSelector.Enum.select.NONE);
        }
      }
      model.setAndUpdateSelection(TreeSelector.Enum.select.ALL);
      return newState;
    },
    changeSelection: function(model) {
      this.base(model);
      return this.applySelection(model);
    }
  });
})(TreeSelector.SelectionStrategies);
