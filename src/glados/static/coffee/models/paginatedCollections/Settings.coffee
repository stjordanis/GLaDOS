glados.useNameSpace 'glados.models.paginatedCollections',
  # --------------------------------------------------------------------------------------------------------------------
  # Elastic Search specific configuration settings
  # --------------------------------------------------------------------------------------------------------------------
  Settings:
    ES_BASE_URL: 'http://wwwdev.ebi.ac.uk/chembl/glados-es'
    ES_INDEXES:
      COMPOUND:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESCompound'
        LABEL: 'Compounds'
        PATH: '/chembl_molecule'
        MODEL: Compound
        COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
      TARGET:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESTarget'
        LABEL: 'Targets'
        PATH:'/chembl_target'
        MODEL: Target
        COLUMNS: Target.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
      ASSAY:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESAssay'
        LABEL: 'Assays'
        PATH:'/chembl_assay'
        MODEL: Assay
        COLUMNS: Assay.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
      DOCUMENT:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESDocument'
        LABEL: 'Documents'
        PATH:'/chembl_document'
        MODEL: Document
        COLUMNS: Document.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
      CELL_LINE:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESCellLine'
        LABEL: 'Cells'
        PATH:'/chembl_cell_line'
        MODEL: CellLine
        COLUMNS: CellLine.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
# TODO: Tissue model is missing
#      TISSUE:
#        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
#        ID_NAME: 'ESTissue'
#        LABEL: 'Tissues'
#        PATH:'/chembl_tissue'
#        MODEL: Tissue
#        COLUMNS: Tissue.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
    WS_COLLECTIONS:
      DRUG_LIST:
        MODEL: Drug
        BASE_URL: glados.Settings.WS_BASE_URL + 'molecule.json'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: [
          {
            'name_to_show': 'ChEMBL ID'
            'comparator': 'molecule_chembl_id'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
            'link_base': 'report_card_url'
            'image_base_url': 'image_url'
          }
          {
            'name_to_show': 'Molecule Type'
            'comparator': 'molecule_type'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Name'
            'comparator': 'pref_name'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Max Phase'
            'comparator': 'max_phase'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Dosed Ingredient:'
            'comparator': 'dosed_ingredient'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
        ]
      SUBSTRUCTURE_OR_SIMILARITY_RESULTS_LIST:
        MODEL: Compound
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
      SUBSTRUCTURE_OR_SIMILARITY_RESULTS_LIST_COMPACT:
        MODEL: Compound
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: "needs to be set up outside, for some reason it doesn't work"
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_COMPACT
        IS_CAROUSEL: true
      DOCS_BY_TERM_LIST:
        MODEL: Document
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: [
          {
            'name_to_show': 'CHEMBL_ID'
            'comparator': 'document_chembl_id'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
            'link_base': 'report_card_url'
          }
          {
            'name_to_show': 'Score'
            'comparator': 'score'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
            'custom_field_template': '<b>Score: </b>{{val}}'
          }
          {
            'name_to_show': 'Title'
            'comparator': 'title'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
            'custom_field_template': '<i>{{val}}</i>'
          }
          {
            'name_to_show': 'Authors'
            'comparator': 'authors'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Year'
            'comparator': 'year'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'

          }
        ]
    CLIENT_SIDE_WS_COLLECTIONS:
      # used for targets
      APPROVED_DRUGS_CLINICAL_CANDIDATES_LIST:
        MODEL: ApprovedDrugClinicalCandidate
        DEFAULT_PAGE_SIZE: 10
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: [
          {
            'name_to_show': 'ChEMBL ID'
            'comparator': 'molecule_chembl_id'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
            'link_base': 'report_card_url'
          }
          {
            'name_to_show': 'Name'
            'comparator': 'pref_name'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Mechanism of Action'
            'comparator': 'mechanism_of_action'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Max Phase'
            'comparator': 'max_phase'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'References'
            'comparator': 'references'
            'sort_disabled': true
            'is_sorting': 0
          }
        ]
      # used for targets
      TARGET_RELATIONS_LIST:
        MODEL: TargetRelation
        DEFAULT_PAGE_SIZE: 5
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: [
          {
            'name_to_show': 'ChEMBL ID'
            'comparator': 'target_chembl_id'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
            'link_base': 'report_card_url'
          }
          {
            'name_to_show': 'Relationship'
            'comparator': 'relationship'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Pref Name'
            'comparator': 'pref_name'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Target Type'
            'comparator': 'target_type'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
        ]

      TARGET_COMPONENTS_LIST:
        MODEL: TargetComponent
        DEFAULT_PAGE_SIZE: 5
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: [
          {
            'name_to_show': 'Description'
            'comparator': 'component_description'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Relationship'
            'comparator': 'relationship'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
          }
          {
            'name_to_show': 'Accession'
            'comparator': 'accession'
            'sort_disabled': false
            'is_sorting': 0
            'sort_class': 'fa-sort'
            'link_base': 'accession_url'
          }
        ]

# fills the KEY_NAME for the ES_INDEXES object
for key_i, val_i of glados.models.paginatedCollections.Settings.ES_INDEXES
  val_i.KEY_NAME = key_i
