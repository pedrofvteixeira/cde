
define([
  'cdf/lib/jquery',
  'amd!cdf/lib/underscore',
  'cdf/Dashboard.Clean',
  'cde/components/TreeSelectorComponent'],
  function( $ , _ , Dashboard, TreeSelector ) {

  describe('TreeSelector.SelectionStrategies.SingleSelect', function() {

    var dashboard = new Dashboard();
    dashboard.init();

    var model, strategy;
    model = void 0;
    strategy = void 0;
    describe('at a depth of 1 level', function() {
      beforeEach(function() {
        strategy = new TreeSelector.SelectionStrategies.SingleSelect(TreeSelector.Enum.selectionStrategy.SingleSelect);
        return model = new TreeSelector.Models.SelectionTree({
          label: 'Parent',
          id: '#parent',
          isSelected: false,
          nodes: _.map(_.range(10), function(n) {
            var result;
            result = {
              label: 'Child #{n}',
              id: "#child" + n,
              isSelected: false
            };
            return result;
          })
        });
      });
      it('successfully marks a single item as selected', function() {
        console.log('TreeSelector.SelectionStrategies.SingleSelect > at a depth of 1 level > successfully marks a single item as selected');
        strategy.setSelection(TreeSelector.Enum.select.ALL, model.children().first());
        strategy.setSelection(TreeSelector.Enum.select.ALL, model.children().last());
        
        expect( model.where({ isSelected: true }).length ).toBe(1);
        expect( model.where({ isSelected: true })[0] ).toBe( model.children().last() );
      });
      it('cannot unselect an item', function() {
        console.log('TreeSelector.SelectionStrategies.SingleSelect > at a depth of 1 level > cannot unselect an item');
        strategy.setSelection(TreeSelector.Enum.select.ALL, model.children().last());
        strategy.setSelection(TreeSelector.Enum.select.NONE, model.children().last());
        
        expect( model.where({ isSelected: true }).length ).toBe(1);
        expect( model.where({ isSelected: true })[0] ).toBe( model.children().last() );
      });
      it('does not allow the root to be selected', function() {
        console.log('TreeSelector.SelectionStrategies.SingleSelect > at a depth of 1 level > does not allow the root to be selected');
        var selectedItems;
        strategy.setSelection(TreeSelector.Enum.select.ALL, model);
        selectedItems = model.where({
          isSelected: true
        }).length;
        
        expect(selectedItems).toBe(0);
      });
    });
    describe('at a depth of 2 levels', function() {
      beforeEach(function() {
        strategy = new TreeSelector.SelectionStrategies.SingleSelect(TreeSelector.Enum.selectionStrategy.SingleSelect);
        return model = new TreeSelector.Models.SelectionTree({
          label: 'Root',
          id: '#root',
          isSelected: false,
          nodes: _.map(_.range(3), function(n) {
            var result1;
            return result1 = {
              label: "Group " + n,
              id: "#group " + n,
              nodes: _.map(_.range(5), function(k) {
                var result2;
                return result2 = {
                  label: "#Item " + n + "." + k,
                  id: "#item " + n + k + "."
                };
              })
            };
          })
        });
      });
      it('successfully marks a single item as selected', function() {
        console.log('TreeSelector.SelectionStrategies.SingleSelect > at a depth of 2 levels > successfully marks a single item as selected');
        strategy.setSelection(TreeSelector.Enum.select.ALL, model.children().first().children().first());
        strategy.setSelection(TreeSelector.Enum.select.ALL, model.children().last().children().last());
        
        expect( model.where({ isSelected: true }).length ).toBe(1);
        expect( model.where({ isSelected: true })[0] ).toBe( model.children().last().children().last() );
      });
      it('cannot unselect an item', function() {
        console.log('TreeSelector.SelectionStrategies.SingleSelect > at a depth of 2 levels > cannot unselect an item');
        strategy.setSelection(TreeSelector.Enum.select.ALL, model.children().last().children().last());
        strategy.setSelection(TreeSelector.Enum.select.NONE, model.children().last().children().last());
        expect( model.where({ isSelected: true }).length ).toBe(1);
        expect( model.where({ isSelected: true })[0] ).toBe( model.children().last().children().last() );
      });
      it('does not allow a group to be selected', function() {
        console.log('TreeSelector.SelectionStrategies.SingleSelect > at a depth of 2 levels > does not allow the root to be selected');
        var selectedItems;
        strategy.setSelection(TreeSelector.Enum.select.ALL, model.children().first());
        selectedItems = model.where({
          isSelected: true
        }).length;
        
        expect( selectedItems ).toBe(0);
      });
    });
  });
});
