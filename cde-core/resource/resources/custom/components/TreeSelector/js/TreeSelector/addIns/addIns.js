'use strict';
(function(Dashboards, AddIn, Renderers) {
  'use strict';
  var myAddIn;
  myAddIn = new AddIn({
    name: 'notificationSelectionLimit',
    label: 'Notification that the selection limit has been reached',
    help: 'Acts on the footer of the Root view',
    defaults: {
      hook: 'footer'
    },
    implementation: function($tgt, st, options) {
      return Renderers.notificationSelectionLimit.call(this, $tgt, st.model, st.configuration);
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'renderRootSelection', myAddIn);
})(Dashboards, AddIn, TreeSelector.Extensions.Renderers);

(function(Dashboards, AddIn, Renderers) {
  'use strict';
  var myAddIn;
  myAddIn = new AddIn({
    name: 'sumSelected',
    label: 'Sum the values of the selected items',
    implementation: function($tgt, st, options) {
      return Renderers.sumSelected.call(this, $tgt, st.model, st.configuration);
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'renderRootSelection', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'renderGroupSelection', myAddIn);
})(Dashboards, AddIn, TreeSelector.Extensions.Renderers);

(function(Dashboards, AddIn) {
  'use strict';
  var myAddIn;
  myAddIn = new AddIn({
    name: 'randomColor',
    label: 'Programmatically sets a random color',
    defaults: {
      selector: '.selector-item-body'
    },
    implementation: function($tgt, model, options) {
      return $tgt.find(options.selector).css({
        color: "rgb(" + (_.random(255)) + "," + (_.random(255)) + "," + (_.random(255)) + ")"
      });
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'renderItemSelection', myAddIn);
})(Dashboards, AddIn);

(function(Dashboards, AddIn, Sorters) {
  'use strict';

  /**
   * Sorts items, by keeping the selected items on top
   */
  var myAddIn;
  myAddIn = new AddIn({
    name: 'selectedOnTop',
    label: 'Keep selected items on top ',
    implementation: function($tgt, st, options) {
      var result;
      result = st.model.getSelection() ? 'A' : 'Z';
      result += st.model.index();
      return result;
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'sortItem', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'sortGroup', myAddIn);
})(Dashboards, AddIn, TreeSelector.Extensions.Sorters);

(function(Dashboards, AddIn, Sorters) {
  'use strict';

  /**
   * Sorts items, by keeping the insertion order
   */
  var myAddIn;
  myAddIn = new AddIn({
    name: 'insertionOrder',
    label: 'Keep insertion order',
    implementation: function($tgt, st, options) {
      var result;
      result = st.model.index();
      return result;
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'sortItem', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'sortGroup', myAddIn);
})(Dashboards, AddIn, TreeSelector.Extensions.Sorters);

(function(Dashboards, AddIn) {
  'use strict';

  /**
   * Sorts items/groups by label
   */
  var myAddIn;
  myAddIn = new AddIn({
    name: 'sortByLabel',
    label: 'Sort items by label, alphabetically',
    defaults: {
      ascending: true
    },
    implementation: function($tgt, st, options) {
      var result, zCode;
      result = st.model.get('label');
      return result;
      if (options.ascending) {
        return result;
      } else {
        zCode = 'z'.codePointAt(0);
        return _.chain(result).map(function(c) {
          return zCode - c.codePointAt(0);
        }).join(' ').value();
      }
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'sortItem', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'sortGroup', myAddIn);
})(Dashboards, AddIn);

(function(Dashboards, AddIn) {
  'use strict';

  /**
   * Sorts items/groups by value
   */
  var myAddIn;
  myAddIn = new AddIn({
    name: 'sortByValue',
    label: 'Sort items by value',
    defaults: {
      ascending: false
    },
    implementation: function($tgt, st, options) {
      var result;
      result = st.model.get('value');
      if (options.ascending) {
        return result;
      } else {
        return -1 * result;
      }
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'sortItem', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'sortGroup', myAddIn);
})(Dashboards, AddIn);

(function(Dashboards, Mustache, AddIn) {
  'use strict';

  /**
   * Sums the values of all the descendants
   */
  var myAddIn;
  myAddIn = new AddIn({
    name: 'sumValues',
    label: 'Sums the values of the selected items',
    defaults: {
      formatValue: function(total) {
        return Mustache.render('{{total}}', {
          total: total
        });
      }
    },
    implementation: function($tgt, st, options) {
      var html, selector, total;
      total = st.model.flatten().filter(function(m) {
        return m.children() == null;
      }).filter(function(m) {
        return m.getSelection() === true;
      }).reduce((function(memo, m) {
        return memo + m.get('value');
      }), 0).value();
      selector = st.model.isRoot() ? '.selector-root-selection-value' : '.selector-group-selection-value';
      if (_.isFinite(total)) {
        html = options.formatValue(total);
      } else {
        html = '';
      }
      return $tgt.find(selector + ':eq(0)').html(html);
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'renderRootSelection', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'renderGroupSelection', myAddIn);
})(Dashboards, Mustache, AddIn);

(function(Dashboards, Mustache, AddIn) {
  'use strict';

  /**
   * Renders a Mustache template
   */
  var myAddIn;
  myAddIn = new AddIn({
    name: 'template',
    label: 'Mustache template',
    defaults: {
      template: '{{label}}',
      selector: '',
      postRender: void 0
    },
    implementation: function($tgt, st, options) {
      var $el, html;
      if (!_.isEmpty(options.template)) {
        html = Mustache.render(options.template, st.model.toJSON());
        $el = $tgt;
        if (!_.isEmpty(options.selector)) {
          $el = $tgt.find(options.selector + ':eq(0)');
        }
        $el.html(html);
        if (_.isFunction(options.postRender)) {
          return options.postRender.call(this, $tgt, st, options);
        }
      }
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'renderRootHeader', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'renderRootFooter', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'renderRootSelection', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'renderGroupSelection', myAddIn);
  Dashboards.registerAddIn('SelectorComponent', 'renderItemSelection', myAddIn);
})(Dashboards, Mustache, AddIn);

(function(Dashboards, AddIn) {
  'use strict';

  /**
   * Emulate accordion behaviour on a group of selectors
  #
   * When the user expands a selector, a global event on the "Dashboards" object is issued.
   * The selectors configured to use this addIn will listen to the event and
   * close themselves accordingly
   */
  var myAddIn;
  myAddIn = new AddIn({
    name: 'accordion',
    label: 'Makes all selectors behave as an accordion',
    defaults: {
      group: 'filters'
    },
    implementation: function($tgt, st, options) {
      st.model.on('change:isCollapsed', function(model, newState) {
        if (newState === false) {
          return Dashboards.trigger('selectors:close', model, options);
        }
      });
      st.model.listenTo(Dashboards, 'selectors:close', function(model, opts) {
        if (opts.group === options.group) {
          if (model !== st.model) {
            if (st.model.get('isDisabled') === false) {
              return st.model.set('isCollapsed', true);
            }
          }
        }
      });
    }
  });
  Dashboards.registerAddIn('SelectorComponent', 'postUpdate', myAddIn);
})(Dashboards, AddIn);