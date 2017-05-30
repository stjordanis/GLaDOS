Assay = Backbone.Model.extend

  idAttribute: 'assay_chembl_id'

  initialize: ->
    @url = glados.Settings.WS_BASE_URL + 'assay/' + @get('assay_chembl_id') + '.json'

  parse: (data) ->
    parsed = data
    parsed.target = data.target_chembl_id

    parsed.report_card_url = Assay.get_report_card_url(parsed.assay_chembl_id )
    return parsed;

Assay.get_report_card_url = (chembl_id)->
  return glados.Settings.GLADOS_BASE_PATH_REL+'assay_report_card/'+chembl_id

Assay.COLUMNS = {

  CHEMBL_ID:{
    'name_to_show': 'CHEMBL_ID'
    'comparator': 'assay_chembl_id'
    'sort_disabled': false
    'is_sorting': 0
    'sort_class': 'fa-sort'
    'link_base': 'report_card_url'
  }
  STRAIN:{
    'name_to_show': 'Strain'
    'comparator': 'assay_strain'
    'sort_disabled': false
    'is_sorting': 0
    'sort_class': 'fa-sort'
    'custom_field_template': '<i>{{val}}</i>'
  }
  DESCRIPTION:{
    'name_to_show': 'Description'
    'comparator': 'description'
    'sort_disabled': false
    'is_sorting': 0
    'sort_class': 'fa-sort'
  }
  ORGANISM:{
    'name_to_show': 'Organism'
    'comparator': 'assay_organism'
    'sort_disabled': false
    'is_sorting': 0
    'sort_class': 'fa-sort'
  }
}

Assay.ID_COLUMN = Assay.COLUMNS.CHEMBL_ID

Assay.COLUMNS_SETTINGS = {
  RESULTS_LIST_TABLE: [
    Assay.COLUMNS.CHEMBL_ID
    Assay.COLUMNS.STRAIN
    Assay.COLUMNS.DESCRIPTION
    Assay.COLUMNS.ORGANISM
  ]
}