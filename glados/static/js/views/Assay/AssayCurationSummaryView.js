// Generated by CoffeeScript 1.4.0
var AssayCurationSummaryView;

AssayCurationSummaryView = CardView.extend({
  initialize: function() {
    return this.model.on('change', this.render, this);
  },
  render: function() {
    var target;
    target = this.model.get('target');
    if (target != null) {
      target.on('change', this.render, this);
    }
    this.fill_template('BCK-ACS-large');
    this.fill_template('BCK-ACS-small');
    return this.showVisibleContent();
  },
  fill_template: function(div_id) {
    var div, target, template;
    target = this.model.get('target');
    div = $(this.el).find('#' + div_id);
    template = $('#' + div.attr('data-hb-template'));
    return div.html(Handlebars.compile(template.html())({
      target_type: target.get('target_type'),
      pref_name: target.get('pref_name'),
      target_chembl_id: target.get('target_chembl_id')
    }));
  }
});
