'use strict';
var App;

App = {};

App.init = function() {
  'use strict';
  var configuration, generateData, outputDataHandlerOptions, renderers, selectorLogic;
  this.dataCDA0 = {
    metadata: [
      {
        colIndex: 0,
        colName: 'id',
        colType: 'string'
      }, {
        colIndex: 1,
        colName: 'value',
        colType: 'string'
      }
    ],
    resultset: [['a', '0 A'], ['b', '0 B']]
  };
  this.dataCDA1 = {
    metadata: [
      {
        colIndex: 0,
        colName: 'id',
        colType: 'string'
      }, {
        colIndex: 1,
        colName: 'value',
        colType: 'string'
      }, {
        colIndex: 2,
        colName: 'groupId',
        colType: 'string'
      }, {
        colIndex: 3,
        colName: 'groupLabel',
        colType: 'string'
      }
    ],
    resultset: [['a', '1 A', 'vowels.all', 'Vowels'], ['b', '1 B', 'consonants.all', 'Consonants'], ['e', '1 E', 'vowels.all', 'Vowels']]
  };
  generateData = function(label, level) {
    return [
      {
        label: label,
        id: level + ".all",
        value: Math.pow(10, level - 1) + _.random(Math.pow(10, level)),
        nodes: _.map(_.range(Math.pow(10, level)), function(v) {
          var node;
          node = {
            label: "Item " + level + "." + v,
            value: _.random(100),
            id: level + "." + v
          };
          return node;
        })
      }
    ];
  };

  /**
   * Build composite model
   */
  this.model = new TreeSelector.Models.SelectionTree({
    label: 'Root Level',
    id: 'root'
  });

  /**
   * Build composite view
   */
  selectorLogic = 'SingleSelect';
  selectorLogic = 'MultiSelect';
  configuration = {};
  configuration.component = $.extend(true, {}, TreeSelector.defaults(), TreeSelector.Enum.logic[selectorLogic]);
  configuration = $.extend(true, configuration, {
    component: {
      target: $('#selector1'),
      pagination: {
        getPage: function(page) {
          var deferred, id, items;
          id = page * _.uniqueId();
          items = _.map(_.range(10), function(v) {
            var item;
            return item = {
              label: "Item " + id + "." + v,
              value: id * 100000 + v
            };
          });
          deferred = $.Deferred();
          deferred.resolve(items);
          return deferred;
        }
      },
      Group: {
        options: {
          showValue: true
        },
        renderers: {
          selection: TreeSelector.Extensions.Renderers.sumSelected
        }
      },
      Item: {
        options: {
          showValue: true,
          showButtonOnlyThis: true
        },
        sorter: TreeSelector.Extensions.Sorters.sortAlphabetically
      }
    }
  });
  renderers = {
    'MultiSelect': TreeSelector.Extensions.Renderers.RootHeaderMultiSelect,
    'LimitedSelect': TreeSelector.Extensions.Renderers.RootHeaderMultiSelect,
    'SingleSelect': TreeSelector.Extensions.Renderers.RootHeaderSingleSelect
  };
  this.logic = new TreeSelector.Logic[configuration.component.logic.type](configuration.component.logic);
  configuration.component.logic.manager = this.logic;
  this.configuration = configuration;
  this.input = new TreeSelector.DataHandlers.Input({
    model: this.model,
    options: {
      inputValueParameter: 'xpto'
    }
  });
  this.manager = new TreeSelector.Controllers.Manager({
    model: this.model,
    configuration: configuration.component
  });
  outputDataHandlerOptions = {
    outputParameter: 'xpto',
    preChange: _.noop,
    postChange: _.noop,
    trigger: ['selection', 'apply'][1]
  };
  this.output = new TreeSelector.DataHandlers.Output({
    model: this.model,
    options: outputDataHandlerOptions
  });

  /**
   * Update the model with new data
   */
  this.model.add(generateData("Medium Group", 2));
  return this.input.setValue(['1.' + _.random(10)]);
};

$(function() {
  'use strict';
  App.init();
  return window.App = App;
});
