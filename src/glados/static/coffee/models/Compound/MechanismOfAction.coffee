glados.useNameSpace 'glados.models.Compound',
  MechanismOfAction: Backbone.Model.extend

    parse: (response) ->

      response.target_link = Target.get_report_card_url(response.target_chembl_id)
      return response

glados.models.Compound.MechanismOfAction.COLUMNS =
  MECH_ID:
    name_to_show: 'ID'
    comparator: 'mec_id'
  MECHANISM_OF_ACTION:
    name_to_show: 'Mechanism Of Action'
    comparator: 'mechanism_of_action'
  TARGET_CHEMBL_ID: glados.models.paginatedCollections.ColumnsFactory.generateColumn Activity.indexName,
    comparator: 'target_chembl_id'
    link_base:'target_link'
  REFERENCES:
    name_to_show: 'References'
    comparator: 'mechanism_refs'
    multiple_links: true
    multiple_links_function: (refs) -> ({text:r.ref_type, url:r.ref_url} for r in refs)


glados.models.Compound.MechanismOfAction.ID_COLUMN = glados.models.Compound.MechanismOfAction.COLUMNS.MECH_ID

glados.models.Compound.MechanismOfAction.COLUMNS_SETTINGS =
  ALL_COLUMNS: (->
    colsList = []
    for key, value of glados.models.Compound.MechanismOfAction.COLUMNS
      colsList.push value
    return colsList
  )()
  RESULTS_LIST_TABLE: [
    glados.models.Compound.MechanismOfAction.COLUMNS.MECHANISM_OF_ACTION
    glados.models.Compound.MechanismOfAction.COLUMNS.TARGET_CHEMBL_ID
    glados.models.Compound.MechanismOfAction.COLUMNS.REFERENCES
  ]