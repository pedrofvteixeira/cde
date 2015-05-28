
/**
 * An intuitive Selector Component with many out-of-the-box features:
 * - pluggable selection logic: single-, multi-, and limited-select
 * - automatic handling of groups of options
 * - searchable
 * - extensible via addIns
 * @class SelectorComponent
 * @constructor
 */

define([
  './Selector/TreeSelector',
  './Selector/base/templates',
  './Selector/base/defaults',
  './Selector/base/Logger',
  './Selector/strategies/SingleSelect',
  './Selector/strategies/MultiSelect',
  './Selector/models/SelectionTree'],
  function( TreeSelector ) {

  return TreeSelector;
});
