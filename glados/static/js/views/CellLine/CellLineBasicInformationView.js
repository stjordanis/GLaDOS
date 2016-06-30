// Generated by CoffeeScript 1.4.0
var CellLineBasicInformationView;

CellLineBasicInformationView = CardView.extend({
  initialize: function() {
    return this.model.on('change', this.render, this);
  },
  render: function() {
    this.render_for_large();
    return this.render_for_small();
  },
  render_for_large: function() {
    var table_large, template;
    table_large = $(this.el).find('#BCK-CBI-large');
    template = $('#' + table_large.attr('data-hb-template'));
    return table_large.html(Handlebars.compile(template.html())({
      chembl_id: this.model.get('cell_chembl_id'),
      name: this.model.get('cell_name'),
      description: this.model.get('cell_description'),
      tissue: this.model.get('cell_source_tissue'),
      organism: this.model.get('cell_source_organism'),
      tax_id: this.model.get('cell_source_tax_id'),
      clo_id: this.model.get('clo_id'),
      efo_id: this.model.get('efo_id'),
      cellosaurus_id: this.model.get('cellosaurus_id')
    }));
  },
  render_for_small: function() {
    var table_large, template;
    table_large = $(this.el).find('#BCK-CBI-small');
    template = $('#' + table_large.attr('data-hb-template'));
    return table_large.html(Handlebars.compile(template.html())({
      chembl_id: this.model.get('cell_chembl_id'),
      name: this.model.get('cell_name'),
      description: this.model.get('cell_description'),
      tissue: this.model.get('cell_source_tissue'),
      organism: this.model.get('cell_source_organism'),
      tax_id: this.model.get('cell_source_tax_id'),
      clo_id: this.model.get('clo_id'),
      efo_id: this.model.get('efo_id'),
      cellosaurus_id: this.model.get('cellosaurus_id')
    }));
  }
});
