class CellLineReportCardApp extends glados.ReportCardApp

  # -------------------------------------------------------------
  # Initialisation
  # -------------------------------------------------------------
  @init = ->

    super
    cellLine = CellLineReportCardApp.getCurrentCellLine()
    CellLineReportCardApp.initBasicInformation()
    CellLineReportCardApp.initAssaySummary()
    CellLineReportCardApp.initActivitySummary()
    CellLineReportCardApp.initAssociatedCompounds()
    cellLine.fetch()

    $('.scrollspy').scrollSpy()
    ScrollSpyHelper.initializeScrollSpyPinner()

  # -------------------------------------------------------------
  # Singleton
  # -------------------------------------------------------------
  @getCurrentCellLine = ->

    if not @currentCellLine?

      chemblID = glados.Utils.URLS.getCurrentModelChemblID()

      @currentCellLine = new CellLine
        cell_chembl_id: chemblID
      return @currentCellLine

    else return @currentCellLine

  # -------------------------------------------------------------
  # Specific section initialization
  # this is functions only initialize a section of the report card
  # -------------------------------------------------------------
  @initBasicInformation = ->

    cellLine = CellLineReportCardApp.getCurrentCellLine()

    new CellLineBasicInformationView
      model: cellLine
      el: $('#CBasicInformation')
      section_id: 'BasicInformation'
      section_label: 'Basic Information'
      report_card_app: @

    if GlobalVariables['EMBEDED']
      cellLine.fetch()

  @initAssaySummary = ->

    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    associatedAssays = CellLineReportCardApp.getAssociatedAssaysAgg(chemblID)

    pieConfig =
      x_axis_prop_name: 'types'
      title: gettext('glados_cell_line__associated_assays_pie_title_base') + chemblID

    viewConfig =
      pie_config: pieConfig
      resource_type: gettext('glados_entities_cell_line_name')
      link_to_all:
        link_text: 'See all assays for cell line ' + chemblID + ' used in this visualisation.'
        url: Assay.getAssaysListURL('cell_chembl_id:' + chemblID)
      embed_section_name: 'related_assays'
      embed_identifier: chemblID

    new glados.views.ReportCards.PieInCardView
      model: associatedAssays
      el: $('#CAssociatedAssaysCard')
      config: viewConfig
      section_id: 'AssaySummary'
      section_label: 'Assay Summary'
      report_card_app: @

    associatedAssays.fetch()


  @initActivitySummary = ->

    #TODO: update when index is ready
    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    bioactivities = CellLineReportCardApp.getAssociatedBioactivitiesAgg(chemblID)

    pieConfig =
      x_axis_prop_name: 'types'
      title: gettext('glados_cell_line__bioactivities_pie_title_base') + chemblID

    viewConfig =
      pie_config: pieConfig
      resource_type: gettext('glados_entities_cell_line_name')
      embed_section_name: 'bioactivities'
      embed_identifier: chemblID
      link_to_all:
        link_text: 'See all bioactivities for cell line ' + chemblID + ' used in this visualisation.'
        url: Activity.getActivitiesListURL()

    new glados.views.ReportCards.PieInCardView
      model: bioactivities
      el: $('#CLAssociatedActivitiesCard')
      config: viewConfig
      section_id: 'BioactivitySummary'
      section_label: 'Activity Summary'
      report_card_app: @

    bioactivities.fetch()

  @initAssociatedCompounds = (chemblID) ->

    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    associatedCompounds = CellLineReportCardApp.getAssociatedCompoundsAgg(chemblID)

    histogramConfig =
      big_size: true
      paint_axes_selectors: true
      properties:
        mwt: glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('Compound', 'FULL_MWT')
        alogp: glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('Compound', 'ALogP')
        psa: glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('Compound', 'PSA')
      initial_property_x: 'mwt'
      x_axis_options: ['mwt', 'alogp', 'psa']
      x_axis_min_columns: 1
      x_axis_max_columns: 20
      x_axis_initial_num_columns: 10
      x_axis_prop_name: 'x_axis_agg'
      title: 'Associated Compounds for Cell Line ' + chemblID
      title_link_url: Compound.getCompoundsListURL()
      range_categories: true

    config =
      histogram_config: histogramConfig
      resource_type: gettext('glados_entities_cell_line_name')
      embed_section_name: 'related_compounds'
      embed_identifier: chemblID

    new glados.views.ReportCards.HistogramInCardView
      el: $('#CLAssociatedCompoundProperties')
      model: associatedCompounds
      target_chembl_id: chemblID
      config: config
      section_id: 'CompoundSummaries'
      section_label: 'Compound Summaries'
      report_card_app: @


    associatedCompounds.fetch()

  # -------------------------------------------------------------
  # Aggregations
  # -------------------------------------------------------------
  @getAssociatedAssaysAgg = (chemblID) ->

    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: 'cell_chembl_id:{{cell_chembl_id}}'
      template_data:
        cell_chembl_id: 'cell_chembl_id'

    aggsConfig =
      aggs:
        types:
          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
          field: '_metadata.assay_generated.type_label'
          size: 20
          bucket_links:

            bucket_filter_template: 'cell_chembl_id:{{cell_chembl_id}} ' +
                                    'AND _metadata.assay_generated.type_label:("{{bucket_key}}"' +
                                    '{{#each extra_buckets}} OR "{{this}}"{{/each}})'
            template_data:
              cell_chembl_id: 'cell_chembl_id'
              bucket_key: 'BUCKET.key'
              extra_buckets: 'EXTRA_BUCKETS.key'

            link_generator: Assay.getAssaysListURL

    associatedAssays = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.ASSAY_INDEX_URL
      query_config: queryConfig
      cell_chembl_id: chemblID
      aggs_config: aggsConfig

    return associatedAssays

  @getAssociatedBioactivitiesAgg = (chemblID) ->

    #TODO: check how to get in index
    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: '*'

    aggsConfig =
      aggs:
        types:
          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
          field: 'standard_type'
          size: 20
          bucket_links:

            bucket_filter_template: 'standard_type:("{{bucket_key}}"' +
                                    '{{#each extra_buckets}} OR "{{this}}"{{/each}})'
            template_data:
              bucket_key: 'BUCKET.key'
              extra_buckets: 'EXTRA_BUCKETS.key'

            link_generator: Activity.getActivitiesListURL

    bioactivities = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.ACTIVITY_INDEX_URL
      query_config: queryConfig
      cell_chembl_id: chemblID
      aggs_config: aggsConfig

    return bioactivities

  @getAssociatedCompoundsAgg = (chemblID) ->

    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: '*'

    aggsConfig =
      aggs:
        x_axis_agg:
          field: 'molecule_properties.full_mwt'
          type: glados.models.Aggregations.Aggregation.AggTypes.RANGE
          min_columns: 1
          max_columns: 20
          num_columns: 10
          bucket_links:
            bucket_filter_template: 'molecule_properties.full_mwt:(>={{min_val}} AND <={{max_val}})'
            template_data:
              min_val: 'BUCKET.from'
              max_val: 'BUCKETS.to'
            link_generator: Compound.getCompoundsListURL

    associatedCompounds = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.COMPOUND_INDEX_URL
      query_config: queryConfig
      target_chembl_id: chemblID
      aggs_config: aggsConfig

    return associatedCompounds
