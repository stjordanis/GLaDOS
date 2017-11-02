class DocumentReportCardApp

  # -------------------------------------------------------------
  # Initialization
  # -------------------------------------------------------------
  @init = ->

    document = DocumentReportCardApp.getCurrentDocument()

    DocumentReportCardApp.initBasicInformation()
    DocumentReportCardApp.initAssayNetwork()
    DocumentReportCardApp.initWordCloud()
    DocumentReportCardApp.initTargetSummary()
    DocumentReportCardApp.initAssaySummary()
    DocumentReportCardApp.initActivitySummary()
    DocumentReportCardApp.initCompoundSummary()

    document.fetch()

    $('.scrollspy').scrollSpy()
    ScrollSpyHelper.initializeScrollSpyPinner()

  # -------------------------------------------------------------
  # Singleton
  # -------------------------------------------------------------
  @getCurrentDocument = ->

    if not @currentDocument?

      chemblID = glados.Utils.URLS.getCurrentModelChemblID()

      @currentDocument = new Document
        document_chembl_id: chemblID
      return @currentDocument

    else return @currentDocument

  # -------------------------------------------------------------
  # Specific section initialization
  # this is functions only initialize a section of the report card
  # -------------------------------------------------------------
  @initBasicInformation = ->

    document = DocumentReportCardApp.getCurrentDocument()

    new DocumentBasicInformationView
      model: document
      el: $('#DBasicInformation')

    if GlobalVariables['EMBEDED']
      document.fetch()

  @initAssayNetwork = ->

    documentAssayNetwork = new DocumentAssayNetwork
      document_chembl_id: glados.Utils.URLS.getCurrentModelChemblID()

    new DocumentAssayNetworkView
      model: documentAssayNetwork
      el: $('#DAssayNetworkCard')

    documentAssayNetwork.fetch()

  @initWordCloud = ->

    docTerms = new DocumentTerms
      document_chembl_id: glados.Utils.URLS.getCurrentModelChemblID()

    new DocumentWordCloudView
      model: docTerms
      el: $('#DWordCloudCard')

    docTerms.fetch()

  @initTargetSummary = ->

    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    relatedTargets = DocumentReportCardApp.getRelatedTargetsAgg(chemblID)

    pieConfig =
      x_axis_prop_name: 'types'
      title: gettext('glados_document__associated_targets_pie_title_base') + chemblID

    viewConfig =
      pie_config: pieConfig
      resource_type: gettext('glados_entities_document_name')
      embed_section_name: 'related_targets'
      embed_identifier: chemblID
      link_to_all:
        link_text: 'See all targets related to ' + chemblID + ' used in this visualisation.'
        url: Target.getTargetsListURL()

    new glados.views.ReportCards.PieInCardView
      model: relatedTargets
      el: $('#DAssociatedTargetsCard')
      config: viewConfig

    relatedTargets.fetch()

  @initAssaySummary = ->

    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    relatedAssays = DocumentReportCardApp.getRelatedAssaysAgg(chemblID)

    pieConfig =
      x_axis_prop_name: 'types'
      title: gettext('glados_document__associated_assays_pie_title_base') + chemblID

    viewConfig =
      pie_config: pieConfig
      resource_type: gettext('glados_entities_document_name')
      embed_section_name: 'related_assays'
      embed_identifier: chemblID
      link_to_all:
        link_text: 'See all assays related to ' + chemblID + ' used in this visualisation.'
        url: Assay.getAssaysListURL('document_chembl_id:' + chemblID)

    new glados.views.ReportCards.PieInCardView
      model: relatedAssays
      el: $('#DAssociatedAssaysCard')
      config: viewConfig

    relatedAssays.fetch()

  @initActivitySummary = ->

    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    relatedActivities = DocumentReportCardApp.getRelatedActivitiesAgg(chemblID)

    pieConfig =
      x_axis_prop_name: 'types'
      title: gettext('glados_document__associated_activities_pie_title_base') + chemblID

    viewConfig =
      pie_config: pieConfig
      resource_type: gettext('glados_entities_document_name')
      embed_section_name: 'related_activities'
      embed_identifier: chemblID
      link_to_all:
        link_text: 'See all activities related to ' + chemblID + ' used in this visualisation.'
        url: Activity.getActivitiesListURL('document_chembl_id:' + chemblID)

    new glados.views.ReportCards.PieInCardView
      model: relatedActivities
      el: $('#DAssociatedActivitiesCard')
      config: viewConfig

    relatedActivities.fetch()


  @initCompoundSummary = ->

    # TODO: update after index is updated https://github.com/chembl/GLaDOS-es/issues/8
    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    associatedCompounds = DocumentReportCardApp.getAssociatedCompoundsAgg(chemblID)

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
      title: 'Associated Compounds for Document ' + chemblID
      title_link_url: Compound.getCompoundsListURL()
      range_categories: true

    config =
      histogram_config: histogramConfig
      resource_type: gettext('glados_entities_document_name')
      embed_section_name: 'related_compounds'
      embed_identifier: chemblID

    new glados.views.ReportCards.HistogramInCardView
      el: $('#DAssociatedCompoundPropertiesCard')
      model: associatedCompounds
      document_chembl_id: chemblID
      config: config


    associatedCompounds.fetch()



  # -------------------------------------------------------------
  # Full Screen views
  # -------------------------------------------------------------
  @initAssayNetworkFS = ->

    GlobalVariables.CHEMBL_ID = URLProcessor.getRequestedChemblID()

    documentAssayNetwork = new DocumentAssayNetwork
      document_chembl_id: GlobalVariables.CHEMBL_ID

    danFSView = new DocumentAssayNetworkFSView
      model: documentAssayNetwork
      el: $('#DAN-Main')

    documentAssayNetwork.fetch()

  # -------------------------------------------------------------
  # Aggregations
  # -------------------------------------------------------------
  @getRelatedTargetsAgg = (chemblID) ->

    #TODO: update when index is updated
    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: '*'

    aggsConfig =
      aggs:
        types:
          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
          field: 'target_type'
          size: 20
          bucket_links:

            bucket_filter_template: 'target_type:("{{bucket_key}}"' +
                                    '{{#each extra_buckets}} OR "{{this}}"{{/each}})'
            template_data:
              bucket_key: 'BUCKET.key'
              extra_buckets: 'EXTRA_BUCKETS.key'

            link_generator: Target.getTargetsListURL

    targetTypes = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.TARGET_INDEX_URL
      query_config: queryConfig
      molecule_chembl_id: chemblID
      aggs_config: aggsConfig

    return targetTypes

  @getRelatedAssaysAgg = (chemblID) ->

    #TODO: update when label for type is in index
    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: 'document_chembl_id:{{document_chembl_id}}'
      template_data:
        document_chembl_id: 'document_chembl_id'

    aggsConfig =
      aggs:
        types:
          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
          field: 'assay_type'
          size: 20
          bucket_links:

            bucket_filter_template: 'document_chembl_id:{{document_chembl_id}} ' +
                                    'AND assay_type:("{{bucket_key}}"' +
                                    '{{#each extra_buckets}} OR "{{this}}"{{/each}})'
            template_data:
              document_chembl_id: 'document_chembl_id'
              bucket_key: 'BUCKET.key'
              extra_buckets: 'EXTRA_BUCKETS.key'

            link_generator: Assay.getAssaysListURL

    assays = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.ASSAY_INDEX_URL
      query_config: queryConfig
      document_chembl_id: chemblID
      aggs_config: aggsConfig

    return assays

  @getRelatedActivitiesAgg = (chemblID) ->

    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: 'document_chembl_id:{{document_chembl_id}}'
      template_data:
        document_chembl_id: 'document_chembl_id'

    aggsConfig =
      aggs:
        types:
          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
          field: 'standard_type'
          size: 20
          bucket_links:

            bucket_filter_template: 'document_chembl_id:{{document_chembl_id}} ' +
                                    'AND standard_type:("{{bucket_key}}"' +
                                    '{{#each extra_buckets}} OR "{{this}}"{{/each}})'
            template_data:
              document_chembl_id: 'document_chembl_id'
              bucket_key: 'BUCKET.key'
              extra_buckets: 'EXTRA_BUCKETS.key'

            link_generator: Activity.getActivitiesListURL

    bioactivities = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.ACTIVITY_INDEX_URL
      query_config: queryConfig
      document_chembl_id: chemblID
      aggs_config: aggsConfig

    return bioactivities

  @getAssociatedCompoundsAgg = (chemblID, minCols=1, maxCols=20, defaultCols=10) ->

    # TODO: update after index is updated. https://github.com/chembl/GLaDOS-es/issues/8
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

