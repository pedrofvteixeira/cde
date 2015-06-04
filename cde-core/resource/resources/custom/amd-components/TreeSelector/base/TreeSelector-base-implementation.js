
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
  './TreeSelector',
  './templates',
  './defaults',
  './Logger'],
  function( TreeSelector ) {

    return TreeSelector;
});
