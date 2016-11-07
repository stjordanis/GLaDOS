// Generated by CoffeeScript 1.4.0
var BrowseTargetAsCirclesNodeView;

BrowseTargetAsCirclesNodeView = Backbone.View.extend({
  initialize: function() {
    this.elem_selector = '#' + $(this.el).attr('id');
    this.model.on('change', this.changed, this);
    return this.model.on(TargetHierarchyNode.NODE_FOCUSED_EVT, this.focused, this);
  },
  events: {
    'click': 'clicked'
  },
  changed: function() {
    d3.select(this.elem_selector).classed('selected', this.model.get('selected') === true);
    return d3.select(this.elem_selector).classed('incomplete', this.model.get('incomplete') === true);
  },
  clicked: function(event) {
    if (event.ctrlKey) {
      return this.model.toggleSelection();
    }
  },
  focused: function() {
    return this.parentView.focusTo(d3.select(this.elem_selector).data()[0]);
  }
});
