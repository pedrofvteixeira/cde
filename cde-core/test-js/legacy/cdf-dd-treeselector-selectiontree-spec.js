describe('TreeSelector.Models.SelectionTree', function() {
    var model;
    model = void 0;
    describe('accepts object literals nested around the "node" property', function() {
      beforeEach(function() {
        return model = new TreeSelector.Models.SelectionTree({
          label: 'Parent',
          id: '#parent',
          nodes: [
            {
              label: 'Child',
              id: '#child'
            }
          ]
        });
      });
      it('has the correct parent id', function() {
        expect(model.get('id')).toBe('#parent');
      });
      it('has a single child', function() {
        expect(model.children().models.length).toBe(1);
      });
    });
    /* commented-out */ xdescribe('accepts object literals nested around an arbitrary property', function() {
      beforeEach(function() {
        var attributes;
        model = new TreeSelector.Models.SelectionTree({
          label: 'Parent',
          id: '#parent',
          xchildren: [
            {
              label: 'Child',
              id: '#child'
            }
          ]
        }, {
          nodesAttribute: 'xchildren'
        });
        attributes = model.flatten().map(function(m) {
          return _.keys(m.attributes);
        }).value().join(', ');
        return console.log('Model attributes:', attributes);
      });
      it('is nesting around the correct property', function() {
        expect(model.nodesAttribute).toBe('xchildren');
      });
      it('has the correct parent id', function() {
        expect(model.get('id')).toBe('#parent');
      });
      it('has a single child', function() {
        expect(model.children().models.length).toBe(1);
      });
    });
    describe('propagates the selection state correctly at a depth of 1 level', function() {
      beforeEach(function() {
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
      it('marks all children as selected upon selecting the root ', function() {
        model.setSelection(true);
        expect(model.flatten().all(function(m) {
          return m.getSelection() === TreeSelector.Enum.select.ALL;
        }).value()).toBe(true);
      });
      it('marks all children as unselected upon unselecting the root', function() {
        model.setSelection(false);
        expect(model.flatten().all(function(m) {
          return m.getSelection() === TreeSelector.Enum.select.NONE;
        }).value()).toBe(true);
      });
      it('is partially selected if only some of its children are selected', function() {
        model.setSelection(false);
        model.children().last().setSelection(TreeSelector.Enum.select.ALL);
        expect(model.getSelection()).toBe(TreeSelector.Enum.select.SOME);
      });
    });
    describe('propagates the selection state correctly at a depth of 2 levels', function() {
      beforeEach(function() {
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
      it('marks all children as selected upon selecting the root ', function() {
        model.setSelection(true);
        expect(model.flatten().all(function(m) {
          return m.getSelection() === TreeSelector.Enum.select.ALL;
        }).value()).toBe(true);
      });
      it('marks all children as unselected upon unselecting the root', function() {
        model.setSelection(false);
        expect(model.flatten().all(function(m) {
          return m.getSelection() === TreeSelector.Enum.select.NONE;
        }).value()).toBe(true);
      });
      it('is partially selected if only some of its children are selected', function() {
        model.setSelection(false);
        model.children().last().children().first().setSelection(TreeSelector.Enum.select.ALL);
        expect(model.getSelection()).toBe(TreeSelector.Enum.select.SOME);
        expect(model.children().last().getSelection()).toBe(TreeSelector.Enum.select.SOME);
      });
    });
});

