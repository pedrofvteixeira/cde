
/**
 * @module TreeSelector
 * @submodule SelectionStrategies
 */
define([
   'amd!cdf/lib/underscore',
   'cdf/components/BaseComponent',
   '../TreeSelector'],
   function( _ , BaseComponent, TreeSelector ) {

  /**
   * Base class for handling the selection logic
   *  - what happens when I click on a particular item
   *  - what rules should be followed
   * @class AbstractSelect
   * @extends Base
   * @uses TreeSelector.Logger
   * @constructor
   */
  TreeSelector.SelectionStrategies.AbstractSelect = BaseComponent.extend( TreeSelector.Logger ).extend({
    ID: 'TreeSelector.SelectionStrategies.AbstractSelect',
    constructor: function(options) {
      return this.isLogicGlobal = true;
    },

    /**
     * Calculates the new state of an item, after the user clicked on it
     * @method getNewState
     * @public
     * @params {Enum} oldState
     * @return {Enum} Returns the next state
     */
    getNewState: function(oldState) {
      switch (oldState) {
        case TreeSelector.Enum.select.NONE:
          return TreeSelector.Enum.select.ALL;
        case TreeSelector.Enum.select.ALL:
          return TreeSelector.Enum.select.NONE;
        case TreeSelector.Enum.select.SOME:
          return TreeSelector.Enum.select.NONE;
      }
    },

    /**
     * Infers the state of a node, based on the current state of its children
     * @method inferSelectionFromChildren
     * @private
     * @params {Array of Enum} childrenStates
     * @return {Enum} Returns the inferred state
     */
    inferSelectionFromChildren: function(childrenStates) {
      var all, none;
      all = _.every(childrenStates, function(el) {
        return el === TreeSelector.Enum.select.ALL;
      });
      none = _.every(childrenStates, function(el) {
        return el === TreeSelector.Enum.select.NONE;
      });
      if (all) {
        return TreeSelector.Enum.select.ALL;
      } else if (none) {
        return TreeSelector.Enum.select.NONE;
      } else {
        return TreeSelector.Enum.select.SOME;
      }
    },

    /**
     * Sets a node in the selection tree to a particular state
     * @method setSelection
     * @protected
     * @params {Enum} newState
     * @params {Object} model
     * @chainable
     */
    setSelection: function(newState, model) {
      throw new Error("NotImplemented");
      return this;
    },

    /**
     * Perform operations on the model, associated with the user clicking on an item
     * @method changeSelection
     * @public
     * @params {Object} model
     * @chainable
     */
    changeSelection: function(model) {
      var c, d, newState, that;
      d = $.now();
      c = TreeSelector.count;
      newState = this.getNewState(model.getSelection());
      newState = this.setSelection(newState, model);
      that = this;
      _.delay(function() {
        return that.debug("Switching " + (model.get('label')) + " to " + newState + " took " + ($.now() - d) + " ms and " + (TreeSelector.count - c) + " renders");
      }, 0);
      return this;
    },

    /**
     * Perform operations on the model, associated with commiting the current selection
     * @method applySelection
     * @public
     * @params {Object} model
     * @chainable
     */
    applySelection: function(model) {
      model.updateSelectedItems();
      model.root().set('isCollapsed', true);
      return this;
    }
  });

  return TreeSelector;
});
