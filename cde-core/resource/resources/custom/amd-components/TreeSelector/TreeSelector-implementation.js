
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
  './base/TreeSelector-base-implementation',
  './strategies/SingleSelect',
  './strategies/MultiSelect',
  './models/SelectionTree',
  './controllers/Manager',
  './data-handlers/InputDataHandler',
  './data-handlers/OutputDataHandler',
  './views/Root',
  './views/Item',
  './views/Group',
  './extensions/renderers',
  './extensions/sorters',
  './addIns/addIns'],
  function( TreeSelector ) {

    return TreeSelector;
});
