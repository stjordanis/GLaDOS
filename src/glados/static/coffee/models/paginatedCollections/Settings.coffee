glados.useNameSpace 'glados.models.paginatedCollections',
  # --------------------------------------------------------------------------------------------------------------------
  # Elastic Search specific configuration settings
  # --------------------------------------------------------------------------------------------------------------------
  Settings:
    ES_BASE_URL: 'https://wwwdev.ebi.ac.uk/chembl/glados-es'
    ES_INDEXES:
      COMPOUND:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESCompound'
        LABEL: 'Compounds'
        INDEX_NAME: 'chembl_molecule'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: Compound
        COLUMNS: Compound.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
            Additional: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
          Cards:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        ID_COLUMN: Compound.ID_COLUMN
        DOWNLOAD_COLUMNS: Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        CUSTOM_DEFAULT_CARD_SIZES:
          small: 12
          medium: 6
          large: 4
        CUSTOM_CARD_SIZE_TO_PAGE_SIZES:
          12: 6
          6: 12
          4: 24
          3: 24
          2: 96
          1: 192
        ENABLE_CARDS_ZOOM: true
        CUSTOM_CARDS_TEMPLATE: 'Handlebars-Common-Paginated-Card-Compound'
        CUSTOM_CARDS_ITEM_VIEW: glados.views.PaginatedViews.ItemCardView
        COMPLICATE_CARDS_VIEW: true
        COMPLICATE_CARDS_COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_LONG
        ADDITIONAL_COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.CompoundSchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV'], glados.Settings.DEFAULT_FILE_FORMAT_NAMES['SDF']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Graph'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES.Bioactivity]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
        ENABLE_COLLECTION_CACHING: true
        POSSIBLE_CARD_SIZES_STRUCT:
          1:
            previous: 1
            next: 2
          2:
            previous: 1
            next: 4
          3:
            previous: 2
            next: 4
          4:
            previous: 2
            next: 6
          6:
            previous: 4
            next: 12
          12:
            previous: 6
            next: 12

      TARGET:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESTarget'
        LABEL: 'Targets'
        INDEX_NAME: 'chembl_target'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: Target
        ID_COLUMN: Target.ID_COLUMN
        COLUMNS: Target.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Target.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
            Additional: Target.COLUMNS_SETTINGS.RESULTS_LIST_ADDITIONAL
          Cards:
            Default: Target.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: Target.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: Target.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        DOWNLOAD_COLUMNS: Target.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.TargetSchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES.Bioactivity]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table']
        ENABLE_COLLECTION_CACHING: true
      ASSAY:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESAssay'
        LABEL: 'Assays'
        INDEX_NAME: 'chembl_assay'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: Assay
        ID_COLUMN: Assay.ID_COLUMN
        COLUMNS: Assay.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Assay.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
            Additional: Assay.COLUMNS_SETTINGS.RESULTS_LIST_ADDITIONAL
          Cards:
            Default: Assay.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Infinite:
            Default: Assay.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Carousel:
            Default: Assay.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        DOWNLOAD_COLUMNS: Assay.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.AssaySchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table']
        ENABLE_COLLECTION_CACHING: true
      DOCUMENT:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESDocument'
        LABEL: 'Documents'
        INDEX_NAME: 'chembl_document'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: Document
        ID_COLUMN: Document.ID_COLUMN
        COLUMNS: Document.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Document.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
            Additional: Document.COLUMNS_SETTINGS.RESULTS_LIST_ADDITIONAL
          Cards:
            Default: Document.COLUMNS_SETTINGS.RESULTS_LIST_CARD
          Infinite:
            Default: Document.COLUMNS_SETTINGS.RESULTS_LIST_CARD
          Carousel:
            Default: Document.COLUMNS_SETTINGS.RESULTS_LIST_CARD
        DOWNLOAD_COLUMNS: Document.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.DocumentSchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table']
        ENABLE_COLLECTION_CACHING: true
      CELL_LINE:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESCellLine'
        LABEL: 'Cells'
        INDEX_NAME: 'chembl_cell_line'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: CellLine
        ID_COLUMN: CellLine.ID_COLUMN
        COLUMNS: CellLine.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: CellLine.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
            Additional: CellLine.COLUMNS_SETTINGS.RESULTS_LIST_ADDITIONAL
          Cards:
            Default: CellLine.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Infinite:
            Default: CellLine.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Carousel:
            Default: CellLine.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        DOWNLOAD_COLUMNS: CellLine.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.CellLineSchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table']
      TISSUE:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESTissue'
        LABEL: 'Tissues'
        INDEX_NAME: 'chembl_tissue'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: glados.models.Tissue
        ID_COLUMN: glados.models.Tissue.ID_COLUMN
        COLUMNS: glados.models.Tissue.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: glados.models.Tissue.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
            Additional: glados.models.Tissue.COLUMNS_SETTINGS.RESULTS_LIST_ADDITIONAL
          Cards:
            Default: glados.models.Tissue.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: glados.models.Tissue.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: glados.models.Tissue.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        DOWNLOAD_COLUMNS: glados.models.Tissue.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.TissueSchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table']
    ES_INDEXES_NO_MAIN_SEARCH:
      ACTIVITY:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESActivitity'
        LABEL: 'Activities'
        INDEX_NAME: 'chembl_activity'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: Activity
        ID_COLUMN: Activity.ID_COLUMN
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Activity.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Activity.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_TABLE
            Additional: Activity.COLUMNS_SETTINGS.RESULTS_LIST_TABLE_ADDITIONAL
          Cards:
            Default: Activity.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: Activity.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: Activity.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        DOWNLOAD_COLUMNS: Activity.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.ActivitySchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table']
      COMPOUND_COOL_CARDS:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESCompound'
        LABEL: 'Compounds'
        INDEX_NAME: 'chembl_molecule'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: Compound
        COLUMNS: Compound.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
            Additional: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
          Cards:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        DOWNLOAD_COLUMNS: Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        ID_COLUMN: Compound.ID_COLUMN
        ENABLE_CARDS_ZOOM: true
        CUSTOM_CARDS_TEMPLATE: 'Handlebars-Common-Paginated-Card-Compound'
        CUSTOM_CARDS_ITEM_VIEW: glados.views.PaginatedViews.ItemCardView
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.CompoundSchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV'], glados.Settings.DEFAULT_FILE_FORMAT_NAMES['SDF']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Graph'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES.Bioactivity]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
        ENABLE_COLLECTION_CACHING: true
      COMPOUND_SUBSTRUCTURE_HIGHLIGHTING:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESCompound'
        LABEL: 'Compounds'
        INDEX_NAME: 'chembl_molecule'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: Compound
        COLUMNS: Compound.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
            Additional: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
          Cards:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        DOWNLOAD_COLUMNS: Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        ID_COLUMN: Compound.ID_COLUMN
        ENABLE_CARDS_ZOOM: true
        CUSTOM_CARDS_TEMPLATE: 'Handlebars-Common-Paginated-Card-Compound'
        CUSTOM_CARDS_ITEM_VIEW: glados.views.PaginatedViews.ItemCardView
        ADDITIONAL_COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.CompoundSchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV'], glados.Settings.DEFAULT_FILE_FORMAT_NAMES['SDF']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Graph'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES.Bioactivity]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
        ENABLE_SUBSTRUCTURE_HIGHLIGHTING: true
        SHOW_SUBSTRUCTURE_HIGHLIGHTING: true
        ENABLE_COLLECTION_CACHING: true
        DISABLE_CACHE_ON_DOWNLOAD: true
      COMPOUND_SIMILARITY_MAPS:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESCompound'
        LABEL: 'Compounds'
        INDEX_NAME: 'chembl_molecule'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: Compound
        COLUMNS: Compound.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
            Additional: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
          Cards:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        DOWNLOAD_COLUMNS: Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS_SIMILARITY
        ID_COLUMN: Compound.ID_COLUMN
        ENABLE_CARDS_ZOOM: true
        CUSTOM_CARDS_TEMPLATE: 'Handlebars-Common-Paginated-Card-Compound'
        CUSTOM_CARDS_ITEM_VIEW: glados.views.PaginatedViews.ItemCardView
        ADDITIONAL_COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.CompoundSchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV'], glados.Settings.DEFAULT_FILE_FORMAT_NAMES['SDF']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Graph'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES.Bioactivity]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
        ENABLE_SIMILARITY_MAPS: true
        SHOW_SIMILARITY_MAPS: true
        ENABLE_COLLECTION_CACHING: true
        DISABLE_CACHE_ON_DOWNLOAD: true
      DRUGS_LIST:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESDrugs'
        LABEL: 'Drugs'
        INDEX_NAME: 'chembl_molecule'
        # PATH: Assigned after this declaration using the INDEX_NAME
        MODEL: glados.models.Compound.Drug
        COLUMNS: glados.models.Compound.Drug.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: glados.models.Compound.Drug.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
            Additional: glados.models.Compound.Drug.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
          Cards:
            Default: glados.models.Compound.Drug.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: glados.models.Compound.Drug.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: glados.models.Compound.Drug.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        DOWNLOAD_COLUMNS: glados.models.Compound.Drug.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS
        ID_COLUMN: glados.models.Compound.Drug.ID_COLUMN
        ENABLE_CARDS_ZOOM: true
        CUSTOM_CARDS_TEMPLATE: 'Handlebars-Common-Paginated-Card-Compound'
        CUSTOM_CARDS_ITEM_VIEW: glados.views.PaginatedViews.ItemCardView
        CUSTOM_CARD_ITEM_VIEW_DETAILS_COLUMNS: glados.models.Compound.Drug.COLUMNS_SETTINGS.CARD_DETAILS
        ADDITIONAL_COLUMNS: Drug.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
        FACETS_GROUPS: glados.models.paginatedCollections.esSchema.CompoundSchema.FACETS_GROUPS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV'], glados.Settings.DEFAULT_FILE_FORMAT_NAMES['SDF']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Graph'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES.Bioactivity]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
        ENABLE_COLLECTION_CACHING: true
        DISABLE_CACHE_ON_DOWNLOAD: true
    WS_COLLECTIONS:
      ACTIVITIES_LIST:
        MODEL: Activity
        BASE_URL: glados.Settings.WS_DEV_BASE_URL + 'activity.json'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Activity.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Activity.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Cards:
            Default: Activity.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: Activity.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: Activity.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        ID_COLUMN: Activity.ID_COLUMN
        ADDITIONAL_COLUMNS:[]
      ASSAYS_LIST:
        MODEL: Assay
        BASE_URL: glados.Settings.WS_BASE_URL + 'assay.json'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Assay.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Assay.COLUMNS_SETTINGS.RESULTS_LIST_CARD
          Cards:
            Default: Assay.COLUMNS_SETTINGS.RESULTS_LIST_CARD
          Infinite:
            Default: Assay.COLUMNS_SETTINGS.RESULTS_LIST_CARD
          Carousel:
            Default: Assay.COLUMNS_SETTINGS.RESULTS_LIST_CARD
        ID_COLUMN: Assay.ID_COLUMN
        ADDITIONAL_COLUMNS:[]
      DRUG_LIST:
        MODEL: Compound
        BASE_URL: glados.Settings.WS_BASE_URL + 'molecule.json'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Cards:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        ID_COLUMN: Compound.ID_COLUMN
        ENABLE_COLLECTION_CACHING: true
      SUBSTRUCTURE_RESULTS_LIST:
        MODEL: Compound
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Cards:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Infinite:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
          Carousel:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        ID_COLUMN: Compound.ID_COLUMN
        ADDITIONAL_COLUMNS:[]
        ENABLE_COLLECTION_CACHING: true
      SIMILARITY_RESULTS_LIST:
        MODEL: Compound
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_SIMILARITY
          Cards:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_SIMILARITY
          Infinite:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_SIMILARITY
          Carousel:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_SIMILARITY
        ID_COLUMN: Compound.ID_COLUMN
        ADDITIONAL_COLUMNS:[]
      COMPOUND_WS_RESULTS_LIST_CAROUSEL:
        MODEL: Compound
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: "needs to be set up outside, for some reason it doesn't work"
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_CAROUSEL
          Cards:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_CAROUSEL
          Infinite:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_CAROUSEL
          Carousel:
            Default: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_CAROUSEL
        ID_COLUMN: Compound.ID_COLUMN
        IS_CAROUSEL: true
      DOCS_BY_TERM_LIST:
        MODEL: Document
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        ID_COLUMN: Document.ID_COLUMN
        COLUMNS: Document.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: Document.COLUMNS_SETTINGS.SEARCH_BY_TERM_RESULTS
          Cards:
            Default: Document.COLUMNS_SETTINGS.SEARCH_BY_TERM_RESULTS
          Infinite:
            Default: Document.COLUMNS_SETTINGS.SEARCH_BY_TERM_RESULTS
          Carousel:
            Default: Document.COLUMNS_SETTINGS.SEARCH_BY_TERM_RESULTS
    CLIENT_SIDE_WS_COLLECTIONS:
      # used for targets
      APPROVED_DRUGS_CLINICAL_CANDIDATES_LIST:
        MODEL: ApprovedDrugClinicalCandidate
        DEFAULT_PAGE_SIZE: 10
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        ID_COLUMN: ApprovedDrugClinicalCandidate.ID_COLUMN
        COLUMNS: ApprovedDrugClinicalCandidate.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: ApprovedDrugClinicalCandidate.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Cards:
            Default: ApprovedDrugClinicalCandidate.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Infinite:
            Default: ApprovedDrugClinicalCandidate.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Carousel:
            Default: ApprovedDrugClinicalCandidate.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
      # used for targets
      TARGET_RELATIONS_LIST:
        MODEL: TargetRelation
        DEFAULT_PAGE_SIZE: 5
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        ID_COLUMN: TargetRelation.ID_COLUMN
        COLUMNS: TargetRelation.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: TargetRelation.ID_COLUMN
          Cards:
            Default: TargetRelation.ID_COLUMN
          Infinite:
            Default: TargetRelation.ID_COLUMN
          Carousel:
            Default: TargetRelation.ID_COLUMN
      TARGET_COMPONENTS_LIST:
        MODEL: TargetComponent
        DEFAULT_PAGE_SIZE: 5
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        ID_COLUMN: TargetComponent.ID_COLUMN
        COLUMNS: TargetComponent.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: TargetComponent.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Cards:
            Default: TargetComponent.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Infinite:
            Default: TargetComponent.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
          Carousel:
            Default: TargetComponent.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
    CLIENT_SIDE_ES_COLLECTIONS:
      BIOACTIVITY_SUMMARY_LIST:
        MODEL: Activity
        DEFAULT_PAGE_SIZE: 20
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        ID_COLUMN: Activity.ID_COLUMN
        COLUMNS: Activity.COLUMNS_SETTINGS.ALL_COLUMNS
        COLUMNS_DESCRIPTION:
          Table:
            Default: []
          Cards:
            Default: []
          Infinite:
            Default: []
          Carousel:
            Default: []

glados.models.paginatedCollections.Settings.ES_INDEX_2_GLADOS_SETTINGS= {}

# fills the KEY_NAME for the ES_INDEXES object
for key_i, val_i of glados.models.paginatedCollections.Settings.ES_INDEXES
  val_i.KEY_NAME = key_i
  val_i.PATH = '/'+val_i.INDEX_NAME
  glados.models.paginatedCollections.Settings.ES_INDEX_2_GLADOS_SETTINGS[val_i.INDEX_NAME] = val_i
for key_i, val_i of glados.models.paginatedCollections.Settings.ES_INDEXES_NO_MAIN_SEARCH
  val_i.KEY_NAME = key_i
  val_i.PATH = '/'+val_i.INDEX_NAME

# Loads the Search results URL's including the ElasticSearch entities configuration
glados.loadSearchResultsURLS()