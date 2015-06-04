
/**
 * @module TreeSelector
 * @submodule Views
 */


define([
    'cdf/lib/jquery',
    'amd!cdf/lib/underscore',
    'cdf/lib/mustache',
    './Abstract'],
    function( $, _, Mustache, TreeSelector ) {

      /**
       * Root View: the part of the selector that
       * remains visible when the selector is collapsed
       * @class Root
       * @extends AbstractView
       * @constructor
       */
      TreeSelector.Views.Root = TreeSelector.Views.AbstractView.extend({
        type: 'Root',
        ID: 'TreeSelector.Views.Root',
        template: {
          skeleton: TreeSelector.templates['Root-skeleton'],
          overlay: TreeSelector.templates['Root-overlay'],
          header: TreeSelector.templates['Root-header'],
          selection: TreeSelector.templates['Root-template'],
          footer: TreeSelector.templates['Root-footer']
        },
        events: {
          'click     .selector-root-header:eq(0)': 'onToggleCollapse',
          'click     .selector-root-selection:eq(0)': 'onSelection',
          'click     .selector-btn-apply:eq(0)': 'onApply',
          'click     .selector-btn-cancel:eq(0)': 'onCancel',
          'mouseover .selector-root-header': 'onMouseOver',
          'mouseout  .selector-root-header': 'onMouseOut',
          'keyup   .selector-filter:eq(0)': 'onFilterChange',
          'change  .selector-filter:eq(0)': 'onFilterChange',
          'click  .selector-filter-clear:eq(0)': 'onFilterClear',
          'click  .selector-overlay': 'onOverlayClick'
        },
        initialize: function(options) {
          this.renderOverlay = this.renderSlot('overlay');
          this.renderHeader = this.renderSlot('header');
          this.renderFooter = this.renderSlot('footer');
          return this.base(options);
        },
        bindToModel: function(model) {
          this.base(model);
          this.onChange(model, 'isCollapsed', this.updateCollapse);
          this.onChange(model, 'isSelected numberOfSelectedItems numberOfItems reachedSelectionLimit', this.updateHeader);
          this.onChange(model, 'isSelected numberOfSelectedItems numberOfItems selectedItems', this.updateSelection);
          this.onChange(model, 'reachedSelectionLimit isBusy', this.updateFooter);
          return this.onChange(model, 'isDisabled', _.bind(this.updateAvailability, this));
        },
        getViewModel: function() {
          var viewModel;
          viewModel = this.base();
          $.extend(viewModel, {
            selectedItems: _.map(this.model.getSelectedItems('label'), function(label) {
              return label + " ";
            }),
            allItemsSelected: this.model.get('numberOfSelectedItems') === this.model.get('numberOfItems'),
            noItemsSelected: this.model.get('numberOfSelectedItems') === 0,
            hasChanged: this.model.hasChanged()
          });
          return viewModel;
        },
        render: function() {
          var viewModel;
          viewModel = this.getViewModel();
          this.renderSkeleton(viewModel);
          this.renderOverlay(viewModel);
          this.renderHeader(viewModel);
          this.renderCollapse(viewModel);
          this.renderSelection(viewModel);
          this.renderFooter(viewModel);
          this.renderAvailability(viewModel);
          return this;
        },
        updateHeader: function() {
          var viewModel;
          viewModel = this.getViewModel();
          this.renderHeader(viewModel);
          return this;
        },
        updateFooter: function() {
          var viewModel;
          viewModel = this.getViewModel();
          this.renderFooter(viewModel);
          return this;
        },
        updateCollapse: function() {
          var viewModel;
          viewModel = this.getViewModel();
          this.renderHeader(viewModel);
          this.renderOverlay(viewModel);
          this.renderCollapse(viewModel);
          return this;
        },
        renderCollapse: function(viewModel) {
          if (viewModel.isDisabled === true) {
            this.$('.selector-root-container').toggleClass('expanded', false).toggleClass('collapsed', true).toggleClass('alwaysExpanded', false);
          } else if (viewModel.alwaysExpanded === true) {
            this.$('.selector-root-container').toggleClass('expanded', false).toggleClass('collapsed', false).toggleClass('always-expanded', true);
          } else if (viewModel.isCollapsed === true) {
            this.$('.selector-root-container').toggleClass('expanded', false).toggleClass('collapsed', true).toggleClass('always-expanded', false);
          } else {
            this.$('.selector-root-container').toggleClass('expanded', true).toggleClass('collapsed', false).toggleClass('always-expanded', false);
          }
          return this;
        },
        updateAvailability: function() {
          var viewModel;
          viewModel = this.getViewModel();
          this.renderAvailability(viewModel);
          return this;
        },
        renderAvailability: function(viewModel) {
          this.$('.selector-root-container').toggleClass('disabled', viewModel.isDisabled === true);
          return this;
        },
        onOverlayClick: function(event) {
          this.trigger("click:outside", this.model);
          if (this.config.view.overlaySimulateClick === true) {
            this.$('.selector-overlay').toggleClass('expanded', false).toggleClass('collapsed', true);
            _.delay(function() {
              var $element, item;
              $element = $(document.elementFromPoint(event.clientX, event.clientY));
              item = _.chain($element.parents()).filter(function(m) {
                return $(m).hasClass('selector-root-header');
              }).first().value();
              if (item != null) {
                return $(item).click();
              }
            }, 0);
          }
          return this;
        }
      });

  return TreeSelector;

});
