// Generated by CoffeeScript 1.4.0
var CompoundNameClassificationView;

CompoundNameClassificationView = Backbone.View.extend({
  initialize: function() {
    this.model.on('change', this.render, this);
    return this.model.on('error', this.showErrorCard, this);
  },
  showErrorCard: function(model, xhr, options) {
    var error_msg, rendered, source;
    $(this.el).children('.card-preolader-to-hide').hide();
    if (xhr.status === 404) {
      error_msg = 'No compound found with id ' + this.model.get('molecule_chembl_id');
    } else {
      error_msg = 'There was an error while loading the compound (' + xhr.status + ' ' + xhr.statusText + ')';
    }
    source = '<i class="fa fa-exclamation-circle"></i> {{msg}}';
    rendered = Handlebars.compile(source)({
      msg: error_msg
    });
    $(this.el).children('.card-load-error').find('#Bck-errormsg').html(rendered);
    return $(this.el).children('.card-load-error').show();
  },
  render: function() {
    var attributes;
    $(this.el).children('.card-preolader-to-hide').hide();
    $(this.el).children(':not(.card-preolader-to-hide, .card-load-error)').show();
    attributes = this.model.toJSON();
    this.renderImage();
    this.renderTitle();
    this.renderPrefName();
    this.renderMaxPhase();
    this.renderMolFormula();
    this.renderSynonymsAndTradeNames();
    this.initEmbedModal();
    this.renderModalPreview();
    this.initDownloadPNGButton();
    return ChemJQ.autoCompile();
  },
  renderTitle: function() {
    return $(this.el).find('#Bck-CHEMBL_ID').text(this.model.get('molecule_chembl_id'));
  },
  renderPrefName: function() {
    var name, rendered, source, text;
    name = this.model.get('pref_name');
    text = name !== null ? name : 'Undefined';
    source = '<span> {{#if undef}}<i>{{/if}} {{name}} {{#if undef}}</i>{{/if}} </span>';
    rendered = Handlebars.compile(source)({
      name: text,
      undef: name === null
    });
    return $(this.el).find('#Bck-PREF_NAME').html(rendered);
  },
  renderMaxPhase: function() {
    var description, phase, phase_class, rendered, show_phase, source, template, tooltip_text;
    phase = this.model.get('max_phase');
    phase_class = 'comp-phase-' + phase;
    show_phase = phase !== 0;
    description = (function() {
      switch (false) {
        case phase !== 1:
          return 'Phase I';
        case phase !== 2:
          return 'Phase II';
        case phase !== 3:
          return 'Phase III';
        case phase !== 4:
          return 'Approved';
        default:
          return 'Undefined';
      }
    })();
    tooltip_text = (function() {
      switch (false) {
        case phase !== 0:
          return 'Phase 0: Exploratory study involving very limited human exposure to the drug, with no ' + 'therapeutic or diagnostic goals (for example, screening studies, microdose studies)';
        case phase !== 1:
          return 'Phase 1: Studies that are usually conducted with healthy volunteers and that emphasize ' + 'safety. The goal is to find out what the drug\'s most frequent and serious adverse events are and, often, ' + 'how the drug is metabolized and excreted.';
        case phase !== 2:
          return 'Phase 2: Studies that gather preliminary data on effectiveness (whether the drug works ' + 'in people who have a certain disease or condition). For example, participants receiving the drug may be ' + 'compared to similar participants receiving a different treatment, usually an inactive substance, called a ' + 'placebo, or a different drug. Safety continues to be evaluated, and short-term adverse events are studied.';
        case phase !== 3:
          return 'Phase 3: Studies that gather more information about safety and effectiveness by studying ' + 'different populations and different dosages and by using the drug in combination with other drugs.';
        case phase !== 4:
          return 'Phase 4: Studies occurring after FDA has approved a drug for marketing. These including ' + 'postmarket requirement and commitment studies that are required of or agreed to by the study sponsor. These ' + 'studies gather additional information about a drug\'s safety, efficacy, or optimal use.';
        default:
          return 'Undefined';
      }
    })();
    source = '<span class="{{class}}"> {{text}} </span>' + '{{#if show_phase}}' + '  <span class="{{class}}"> {{desc}} </span>' + '{{/if}}' + '<span class="chembl-help">' + ' <sub><span class="icon-help hoverable tooltipped indigo-text" data-tooltip="{{tooltip}}" data-position="top"></span></sub>' + '</span>';
    template = Handlebars.compile(source);
    rendered = template({
      "class": phase_class,
      text: phase,
      desc: description,
      show_phase: show_phase,
      tooltip: tooltip_text
    });
    $(this.el).find('#Bck-MAX_PHASE').html(rendered);
    return $(this.el).find('#Bck-MAX_PHASE').find('.tooltipped').tooltip();
  },
  renderMolFormula: function() {
    if (this.model.get('structure_type') === 'SEQ') {
      return $(this.el).find('#Bck-MOLFORMULA').parent().parent().hide();
    } else {
      return $(this.el).find('#Bck-MOLFORMULA').text(this.model.get('molecule_properties')['full_molformula']);
    }
  },
  renderImage: function() {
    var img, img_url;
    if (this.model.get('structure_type') === 'NONE') {
      img_url = '/static/img/structure_not_available.png';
    } else if (this.model.get('structure_type') === 'SEQ') {
      img_url = '/static/img/protein_structure.png';
    } else {
      img_url = 'https://www.ebi.ac.uk/chembl/api/data/image/' + this.model.get('molecule_chembl_id');
    }
    img = $(this.el).find('#Bck-COMP_IMG');
    img.error(function() {
      return img.attr('src', '/static/img/structure_not_found.png');
    });
    return img.attr('src', img_url);
  },
  renderSynonymsAndTradeNames: function() {
    var all_syns, syn_rendered, synonyms_source, tn_rendered, trade_names, tradenames_source, unique_synonyms;
    all_syns = this.model.get('molecule_synonyms');
    unique_synonyms = new Set();
    trade_names = new Set();
    $.each(all_syns, function(index, value) {
      if (value.syn_type === 'TRADE_NAME') {
        return trade_names.add(value.synonyms);
      }
    });
    $.each(all_syns, function(index, value) {
      if (value.syn_type !== 'TRADE_NAME' && !trade_names.has(value.synonyms)) {
        return unique_synonyms.add(value.synonyms);
      }
    });
    if (unique_synonyms.size === 0) {
      $(this.el).find('#CompNameClass-synonyms').parent().parent().parent().hide();
    } else {
      synonyms_source = '{{#each items}}' + ' <span class="CNC-chip-syn">{{ this }}</span> ' + '{{/each}}';
      syn_rendered = Handlebars.compile(synonyms_source)({
        items: Array.from(unique_synonyms)
      });
      $(this.el).find('#CompNameClass-synonyms').html(syn_rendered);
    }
    if (trade_names.size === 0) {
      return $(this.el).find('#CompNameClass-tradenames').parent().parent().parent().hide();
    } else {
      tradenames_source = '{{#each items}}' + ' <span class="CNC-chip-tn">{{ this }}</span> ' + '{{/each}}';
      tn_rendered = Handlebars.compile(tradenames_source)({
        items: Array.from(trade_names)
      });
      return $(this.el).find('#CompNameClass-tradenames').html(tn_rendered);
    }
  },
  initEmbedModal: function() {
    var code_elem, modal, rendered, source;
    modal = $(this.el).find('#CNC-embed-modal');
    code_elem = modal.find('code');
    source = '<object ' + 'data="http://glados-ebitest.rhcloud.com//compound_report_card/{{chembl_id}}/embed/name_and_classification/" ' + 'width="360px" height="600px"></object>';
    rendered = Handlebars.compile(source)({
      chembl_id: this.model.get('molecule_chembl_id')
    });
    return code_elem.text(rendered);
  },
  renderModalPreview: function() {
    var code_elem, code_to_preview, modal, preview_elem;
    modal = $(this.el).find('#CNC-embed-modal');
    preview_elem = modal.find('.embed-preview');
    code_elem = modal.find('code');
    code_to_preview = code_elem.text();
    return preview_elem.html(code_to_preview);
  },
  initDownloadPNGButton: function() {
    var img_url;
    img_url = 'https://www.ebi.ac.uk/chembl/api/data/image/' + this.model.get('molecule_chembl_id');
    $('.CNC-download-png').attr('href', img_url);
    return $('.CNC-download-png').attr('download', this.model.get('molecule_chembl_id') + '.png');
  }
});
