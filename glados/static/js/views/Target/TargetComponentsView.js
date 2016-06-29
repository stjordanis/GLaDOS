// Generated by CoffeeScript 1.4.0
var TargetComponentsView;

TargetComponentsView = CardView.extend({
  initialize: function() {
    this.model.on('change', this.render, this);
    this.model.on('error', this.showCompoundErrorCard, this);
    return this.resource_type = 'Target';
  },
  render: function() {
    if (this.model.get('target_components').length === 0) {
      $('#TargetComponents').hide();
      $('#TargetComponents').next().hide();
      $(this.el).hide();
      return;
    }
    this.render_for_large();
    this.render_for_small();
    this.showVisibleContent();
    this.initEmbedModal('components');
    return this.activateModals();
  },
  render_for_large: function() {
    var table_large, template;
    table_large = $(this.el).find('#BCK-Components-large');
    template = $('#' + table_large.attr('data-hb-template'));
    return table_large.html(Handlebars.compile(template.html())({
      components: this.model.get('target_components')
    }));
  },
  render_for_small: function() {
    var table_large, template;
    table_large = $(this.el).find('#BCK-Components-small');
    template = $('#' + table_large.attr('data-hb-template'));
    return table_large.html(Handlebars.compile(template.html())({
      components: this.model.get('target_components')
    }));
  }
});
