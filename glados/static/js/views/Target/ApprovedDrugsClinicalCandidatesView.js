// Generated by CoffeeScript 1.4.0
var ApprovedDrugsClinicalCandidatesView;

ApprovedDrugsClinicalCandidatesView = CardView.extend({
  initialize: function() {
    this.collection.on('reset', this.render, this);
    return this.resource_type = 'Target';
  },
  events: {
    'click .page-selector': 'getPage'
  },
  render: function() {
    if (this.collection.size() === 0) {
      $('#ApprovedDrugsAndClinicalCandidates').hide();
      return;
    }
    this.clearTable();
    this.clearList();
    this.fill_template('ADCCTable-large');
    this.fill_template('ADCCUL-small');
    this.fillPaginator();
    this.showVisibleContent();
    this.initEmbedModal('approved_drugs_clinical_candidates');
    return this.activateModals();
  },
  fill_template: function(elem_id) {
    var adcc, elem, new_row_cont, template, _i, _len, _ref, _results;
    elem = $(this.el).find('#' + elem_id);
    template = $('#' + elem.attr('data-hb-template'));
    _ref = this.collection.models;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      adcc = _ref[_i];
      new_row_cont = Handlebars.compile(template.html())({
        molecule_chembl_id: adcc.get('molecule_chembl_id'),
        pref_name: adcc.get('pref_name'),
        mechanism_of_action: adcc.get('mechanism_of_action'),
        max_phase: adcc.get('max_phase')
      });
      _results.push(elem.append($(new_row_cont)));
    }
    return _results;
  },
  fillPaginator: function() {
    var current_page, elem, first_record, last_page, page_size, records_in_page, template;
    elem = $(this.el).find('#ADCCUL-paginator');
    template = $('#' + elem.attr('data-hb-template'));
    console.log(this.collection.getMeta('total_records'));
    current_page = this.collection.getMeta('current_page');
    records_in_page = this.collection.getMeta('records_in_page');
    console.log('records in page');
    console.log(records_in_page);
    page_size = this.collection.getMeta('page_size');
    first_record = (current_page - 1) * page_size;
    last_page = first_record + records_in_page;
    elem.html(Handlebars.compile(template.html())({
      total_pages: this.collection.getMeta('total_pages'),
      records_showing: first_record + '-' + last_page,
      total_records: this.collection.getMeta('total_records')
    }));
    this.activateCurrentPageButton();
    return this.enableDisableNextLastButtons();
  },
  clearTable: function() {
    return $('#ADCCTable-large tr:gt(0)').remove();
  },
  clearList: function() {
    return $('#ADCCUL-small').empty();
  },
  getPage: function(event) {
    var clicked, current_page, requested_page_num;
    clicked = $(event.currentTarget);
    if (clicked.hasClass('disabled')) {
      return;
    }
    requested_page_num = clicked.attr('data-page');
    current_page = this.collection.getMeta('current_page');
    console.log('current_page');
    console.log(current_page);
    if (current_page === requested_page_num) {
      return;
    }
    if (requested_page_num === "previous") {
      requested_page_num = current_page - 1;
    } else if (requested_page_num === "next") {
      requested_page_num = current_page + 1;
    }
    console.log('going to fetch');
    console.log(requested_page_num);
    this.collection.fetchPage(requested_page_num);
    return this.showPreloader();
  },
  enableDisableNextLastButtons: function() {
    var current_page, total_pages;
    current_page = this.collection.getMeta('current_page');
    total_pages = this.collection.getMeta('total_pages');
    if (current_page === 1) {
      $(this.el).find("[data-page='previous']").addClass('disabled');
    } else {
      $(this.el).find("[data-page='previous']").removeClass('disabled');
    }
    if (current_page === total_pages) {
      return $(this.el).find("[data-page='next']").addClass('disabled');
    } else {
      return $(this.el).find("[data-page='next']").removeClass('disabled');
    }
  },
  activateCurrentPageButton: function() {
    var current_page;
    current_page = this.collection.getMeta('current_page');
    $(this.el).find('.page-selector').removeClass('active');
    return $(this.el).find("[data-page=" + current_page + "]").addClass('active');
  }
});
