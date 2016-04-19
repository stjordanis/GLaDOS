// Generated by CoffeeScript 1.4.0
var CompoundNameClassificationView;

CompoundNameClassificationView = CardView.extend({
  initialize: function() {
    this.model.on('change', this.render, this);
    return this.model.on('error', this.showCompoundErrorCard, this);
  },
  render: function() {
    this.renderTitle();
    this.renderPrefName();
    this.renderMaxPhase();
    this.renderMolFormula();
    this.renderSynonymsAndTradeNames();
    this.showVisibleContent();
    this.initEmbedModal('name_and_classification');
    this.activateTooltips();
    this.activateModals();
    return ChemJQ.autoCompile();
  },
  renderTitle: function() {
    return $(this.el).find('#Bck-CHEMBL_ID').text(this.model.get('molecule_chembl_id'));
  },
  renderPrefName: function() {
    var name, rendered, text;
    name = this.model.get('pref_name');
    text = name !== null ? name : 'Undefined';
    rendered = Handlebars.compile($('#Handlebars-Compound-NameAndClassification-renderPrefName').html())({
      name: text,
      undef: name === null
    });
    return $(this.el).find('#Bck-PREF_NAME').html(rendered);
  },
  renderMaxPhase: function() {
    var description, phase, phase_class, rendered, show_phase, template, tooltip_text;
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
    template = Handlebars.compile($('#Handlebars-Compound-NameAndClassification-renderMaxPhase').html());
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
  renderSynonymsAndTradeNames: function() {
    var all_syns, syn_rendered, synonyms_source, tn_rendered, trade_names, unique_synonyms;
    all_syns = this.model.get('molecule_synonyms');
    unique_synonyms = {};
    trade_names = {};
    $.each(all_syns, function(index, value) {
      if (value.syn_type === 'TRADE_NAME') {
        return trade_names[value.synonyms] = value.synonyms;
      }
    });
    $.each(all_syns, function(index, value) {
      if (value.syn_type !== 'TRADE_NAME' && !(trade_names[value.synonyms] != null)) {
        return unique_synonyms[value.synonyms] = value.synonyms;
      }
    });
    if (Object.keys(unique_synonyms).length === 0) {
      $(this.el).find('#CompNameClass-synonyms').parent().parent().parent().hide();
    } else {
      synonyms_source = '{{#each items}}' + ' <span class="chip-syn">{{ this }}</span> ' + '{{/each}}';
      syn_rendered = Handlebars.compile($('#Handlebars-Compound-NameAndClassification-synonyms').html())({
        items: Object.keys(unique_synonyms)
      });
      $(this.el).find('#CompNameClass-synonyms').html(syn_rendered);
    }
    if (Object.keys(trade_names).length === 0) {
      return $(this.el).find('#CompNameClass-tradenames').parent().parent().parent().hide();
    } else {
      tn_rendered = Handlebars.compile($('#Handlebars-Compound-NameAndClassification-tradenames').html())({
        items: Object.keys(trade_names)
      });
      return $(this.el).find('#CompNameClass-tradenames').html(tn_rendered);
    }
  }
});
