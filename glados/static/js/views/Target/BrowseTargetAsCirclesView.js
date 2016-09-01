// Generated by CoffeeScript 1.4.0
var BrowseTargetAsCirclesView;

BrowseTargetAsCirclesView = Backbone.View.extend(ResponsiviseViewExt).extend({
  initialize: function() {
    var updateViewProxy;
    this.showPreloader();
    updateViewProxy = this.setUpResponsiveRender();
    return this.model.on('change', updateViewProxy, this);
  },
  render: function() {
    var circle, color, diameter, elem_selector, focus, margin, node, nodes, pack, root, svg, text, view, zoom, zoomTo;
    console.log('nodes before');
    console.log(this.model.get('plain'));
    this.hidePreloader();
    margin = 20;
    diameter = $(this.el).width();
    if (diameter === 0) {
      diameter = 300;
    }
    color = d3.scale.linear().domain([-1, 5]).range(["#eceff1", "#607d8b"]).interpolate(d3.interpolateRgb);
    pack = d3.layout.pack().padding(2).size([diameter - margin, diameter - margin]).value(function(d) {
      return d.size;
    });
    elem_selector = '#' + $(this.el).attr('id');
    svg = d3.select(elem_selector).append("svg").attr("width", diameter).attr("height", diameter).append("g").attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");
    root = this.model.get('plain');
    focus = root;
    nodes = pack.nodes(root);
    view = void 0;
    console.log('nodes after');
    console.log(nodes);
    circle = svg.selectAll('circle').data(nodes).enter().append('circle').attr("class", function(d) {
      if (d.parent) {
        if (d.children) {
          return 'node';
        } else {
          return 'node node--leaf';
        }
      } else {
        return 'node node--root';
      }
    }).attr("id", function(d) {
      if (d.parent) {
        return 'circleFor-' + d.id;
      } else {
        return 'circleFor-Root';
      }
    }).style("fill", function(d) {
      if (d.children) {
        return color(d.depth);
      } else {
        return null;
      }
    }).on("click", function(d) {
      if (focus !== d) {
        zoom(d);
        d3.event.stopPropagation();
      }
    });
    text = svg.selectAll('text').data(nodes).enter().append('text').attr("class", "label").style("fill-opacity", function(d) {
      if (d.parent === root) {
        return 1;
      } else {
        return 0;
      }
    }).style("display", function(d) {
      if (d.parent === root) {
        return 'inline';
      } else {
        return 'none';
      }
    }).text(function(d) {
      return d.name + " (" + d.size + ")";
    });
    this.createCircleViews();
    node = svg.selectAll("circle,text");
    d3.select(elem_selector).on("click", function() {
      return zoom(root);
    });
    zoomTo = function(v) {
      var k;
      k = diameter / v[2];
      view = v;
      node.attr("transform", function(d) {
        return "translate(" + (d.x - v[0]) * k + "," + (d.y - v[1]) * k + ")";
      });
      return circle.attr("r", function(d) {
        return d.r * k;
      });
    };
    zoom = function(d) {
      var focus0, transition;
      focus0 = focus;
      focus = d;
      transition = d3.transition().duration(d3.event.altKey ? 7500 : 750).tween("zoom", function(d) {
        var i;
        i = d3.interpolateZoom(view, [focus.x, focus.y, focus.r * 2 + margin]);
        return function(t) {
          return zoomTo(i(t));
        };
      });
      return transition.selectAll("text").filter(function(d) {
        return d.parent === focus || this.style.display === 'inline';
      }).style('fill-opacity', function(d) {
        if (d.parent === focus) {
          return 1;
        } else {
          return 0;
        }
      }).each('start', function(d) {
        if (d.parent === focus) {
          this.style.display = 'inline';
        }
      }).each('end', function(d) {
        if (d.parent !== focus) {
          this.style.display = 'none';
        }
      });
    };
    return zoomTo([root.x, root.y, root.r * 2 + margin]);
  },
  createCircleViews: function() {
    var nodes_dict;
    nodes_dict = this.model.get('all_nodes_dict');
    return $(this.el).find('circle').each(function() {
      var circle, nodeModel, nodeModelID, nodeView;
      circle = $(this);
      nodeModelID = circle.attr('id').replace('circleFor-', '');
      if (nodeModelID === 'Root') {
        return;
      }
      nodeModel = nodes_dict[nodeModelID];
      return nodeView = new BrowseTargetAsCirclesNodeView({
        model: nodeModel,
        el: circle
      });
    });
  }
});
