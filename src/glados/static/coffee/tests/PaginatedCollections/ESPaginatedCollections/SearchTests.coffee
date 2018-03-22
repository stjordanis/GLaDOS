describe "An elasticsearch collection", ->
  esList = glados.models.paginatedCollections.PaginatedCollectionFactory.getAllESResultsListDict()[\
  glados.models.paginatedCollections.Settings.ES_INDEXES.COMPOUND.KEY_NAME
  ]

  esSearchQuery = JSON.parse('{"bool":{"boost":1,"must":{"bool":{"should":[{"multi_match":{"type":"most_fields","fields":["*.std_analyzed^1.6","*.eng_analyzed^0.8","*.ws_analyzed^1.4","*.keyword^2","*.lower_case_keyword^1.5","*.alphanumeric_lowercase_keyword^1.3"],"query":"Aspirin","fuzziness":0,"minimum_should_match":"100%","boost":10}},{"multi_match":{"type":"best_fields","fields":["*.std_analyzed^1.6","*.eng_analyzed^0.8","*.ws_analyzed^1.4","*.keyword^2","*.lower_case_keyword^1.5","*.alphanumeric_lowercase_keyword^1.3"],"query":"Aspirin","fuzziness":0,"minimum_should_match":"100%","boost":2}},{"multi_match":{"type":"phrase","fields":["*.std_analyzed^1.6","*.eng_analyzed^0.8","*.ws_analyzed^1.4","*.keyword^2","*.lower_case_keyword^1.5","*.alphanumeric_lowercase_keyword^1.3"],"query":"Aspirin","minimum_should_match":"100%","boost":1.5}},{"multi_match":{"type":"phrase_prefix","fields":["*.std_analyzed^1.6","*.eng_analyzed^0.8","*.ws_analyzed^1.4","*.keyword^2","*.lower_case_keyword^1.5","*.alphanumeric_lowercase_keyword^1.3"],"query":"Aspirin","minimum_should_match":"100%"}},{"multi_match":{"type":"most_fields","fields":["*.entity_id^2","*.id_reference^1.5","*.chembl_id^2","*.chembl_id_reference^1.5"],"query":"Aspirin","fuzziness":0,"boost":10}}],"must":[]}},"filter":[]}}')

  beforeEach (done) ->
    esList = glados.models.paginatedCollections.PaginatedCollectionFactory.getAllESResultsListDict()[\
    glados.models.paginatedCollections.Settings.ES_INDEXES.COMPOUND.KEY_NAME
    ]
    esList.setMeta('singular_terms', ['aspirin'])
    esList.setMeta('exact_terms', ['"CHEMBL59"'])
    esList.setMeta('filter_terms', [])
    esList.resetSortData()

    esList.setMeta('esSearchQuery', esSearchQuery)
    done()

  it "Sets initial parameters", ->
    expect(esList.getMeta('current_page')).toBe(1)
    expect(esList.getMeta('index')).toBe('/chembl_molecule')
    expect(esList.getMeta('page_size')).toBe(24)
    expect(esList.getMeta('all_items_selected')).toBe(false)
    expect(Object.keys(esList.getMeta('selection_exceptions')).length).toBe(0)

  it "Sets the request data to get the 5th page", ->
    esList.setPage(5)
    expect(esList.getURL()).toBe(glados.models.paginatedCollections.Settings.ES_BASE_URL + '/chembl_molecule/_search')

    requestData = esList.getRequestData()
    expect(requestData['from']).toBe(0)
    expect(requestData['size']).toBe(24)

  it "Sets the request data to switch to 10 items per page", ->
    esList.resetPageSize(10)
    expect(esList.getURL()).toBe(glados.models.paginatedCollections.Settings.ES_BASE_URL + '/chembl_molecule/_search')

    requestData = esList.getRequestData()
    expect(requestData['from']).toBe(0)
    expect(requestData['size']).toBe(10)

  testIteratesPages = (esList, pageSize, totalPages) ->

    for pageNumber in [1..totalPages]
      requestData = esList.setPage(pageNumber, doFetch=true, testMode=true)
      expect(requestData['from']).toBe(pageSize * (pageNumber - 1))
      expect(requestData['size']).toBe(pageSize)

  testIteratesPagesWithDifferentPageSizes = (esList, totalRecords) ->
    esList.setMeta('total_records', totalRecords)

    for pageSize in [1..totalRecords]
      esList.setMeta('page_size', pageSize)
      totalPages = Math.ceil(totalRecords / pageSize)
      esList.setMeta('total_pages', totalPages)
      testIteratesPages(esList, pageSize, totalPages)

  it 'updates the request data as the pagination moves', ->

    totalRecords = 100
    esList.setMeta('total_records', totalRecords)
    pageSize = 10
    esList.setMeta('page_size', pageSize)
    totalPages = Math.ceil(totalRecords / pageSize)
    esList.setMeta('total_pages', totalPages)
    testIteratesPages(esList, pageSize, totalPages)

  it 'updates the request data as the pagination moves, with different pager sizes', ->

    totalRecords = 100
    testIteratesPagesWithDifferentPageSizes(esList, totalRecords)

  it 'updates the state for sorting (asc)', ->

    sortingComparator = 'molecule_chembl_id'
    esList.sortCollection(sortingComparator)
    columns = esList.getMeta('columns')
    for col in columns
      if col.comparator == sortingComparator
        expect(col.is_sorting).toBe(1)
      else
        expect(col.is_sorting).toBe(0)

  it 'updates the state for sorting (desc)', ->

    sortingComparator = 'molecule_chembl_id'
    esList.sortCollection(sortingComparator)
    esList.sortCollection(sortingComparator)
    columns = esList.getMeta('columns')
    for col in columns
      if col.comparator == sortingComparator
        expect(col.is_sorting).toBe(-1)
      else
        expect(col.is_sorting).toBe(0)

  it 'resets sorting', ->

    esList.resetSortData()
    columns = esList.getMeta('columns')
    for col in columns
      expect(col.is_sorting).toBe(0)

  it 'generates the request data for sorting (asc)', ->

    sortingComparator = 'molecule_chembl_id'
    esList.sortCollection(sortingComparator)
    requestData = esList.getRequestData()
    sortingInfo = requestData.sort[0]
    console.log 'sortingInfo: ', sortingInfo
    expect(sortingInfo[sortingComparator]?).toBe(true)
    expect(sortingInfo[sortingComparator].order).toBe('asc')

  it 'generates the request data for sorting (desc)', ->

    sortingComparator = 'molecule_chembl_id'
    esList.sortCollection(sortingComparator)
    esList.sortCollection(sortingComparator)
    requestData = esList.getRequestData()
    sortingInfo = requestData.sort[0]
    expect(sortingInfo[sortingComparator]?).toBe(true)
    expect(sortingInfo[sortingComparator].order).toBe('desc')

  #-------------------------------------------------------------------------------------------------------------------
  # State saving
  #-------------------------------------------------------------------------------------------------------------------
  it "generates a state object", -> TestsUtils.testSavesList(esList,
      pathInSettingsMustBe='ES_INDEXES.COMPOUND',
      queryStringMustBe="*",
      useQueryStringMustBe=false,
      stickyQueryMustBe=undefined,
      esSearchQueryMustBe=esSearchQuery)

  it 'creates a list from a state object', -> TestsUtils.testRestoredListIsEqualToOriginal(esList)

  describe "Downloads", ->

    it 'generates the correct query to download a list of IDs', ->

      idsList = ["CHEMBL2605", "CHEMBL251"]
      page = 1
      pageSize = 10
      requestData = esList.getRequestDataForChemblIDs(page, pageSize, idsList)

      idPropertyName = esList.getMeta('id_column').comparator
      expect(requestData.from).toBe(page - 1)
      expect(requestData.size).toBe(pageSize)
      expect(requestData.query.terms[idPropertyName]?).toBe(true)
      termsGot = requestData.query.terms[idPropertyName]
      expect(TestsUtils.listsAreEqual(termsGot, idsList)).toBe(true)

  describe 'Faceting: ', ->

    beforeAll (done) ->

      TestsUtils.simulateFacetsESList(esList, glados.Settings.STATIC_URL + 'testData/FacetsTestData.json', done)

    beforeEach ->
      esList.clearAllFacetsSelections()

    it 'starts with all facets unselected', ->

      facetGroups = esList.getFacetsGroups()
      for fGroupKey, fGroup of facetGroups
        for fKey, fData of fGroup.faceting_handler.faceting_data
          expect(fData.selected).toBe(false)

    it 'clears all facets selection', ->

      facetGroups = esList.getFacetsGroups()
      testFacetGroupKey = 'max_phase'
      testFacetKey = facetGroups[testFacetGroupKey].faceting_handler.faceting_keys_inorder[0]
      facetingHandler = facetGroups[testFacetGroupKey].faceting_handler
      facetingHandler.toggleKeySelection(testFacetKey)

      esList.clearAllFacetsSelections()

      for fGroupKey, fGroup of facetGroups
        for fKey, fData of fGroup.faceting_handler.faceting_data
          console.log "DEBUGGING", fData
          expect(fData.selected).toBe(false)

    it 'selects one facet', ->

      facetGroups = esList.getFacetsGroups()
      testFacetGroupKey = 'max_phase'
      testFacetKey = facetGroups[testFacetGroupKey].faceting_handler.faceting_keys_inorder[0]
      facetingHandler = facetGroups[testFacetGroupKey].faceting_handler
      facetingHandler.toggleKeySelection(testFacetKey)

      expect(facetGroups[testFacetGroupKey].faceting_handler.faceting_data[testFacetKey].selected).toBe(true)


    describe 'After selecting a facet', ->

      beforeAll (done) ->

        esList = glados.models.paginatedCollections.PaginatedCollectionFactory.getAllESResultsListDict()[\
        glados.models.paginatedCollections.Settings.ES_INDEXES.COMPOUND.KEY_NAME
        ]
        TestsUtils.simulateFacetsESList(esList, glados.Settings.STATIC_URL + 'testData/FacetsTestData.json', done)

      beforeEach ->

        esList.setMeta('esSearchQuery', esSearchQuery)
        facetGroups = esList.getFacetsGroups()
        testFacetGroupKey = 'max_phase'
        testFacetKey = facetGroups[testFacetGroupKey].faceting_handler.faceting_keys_inorder[0]
        facetingHandler = facetGroups[testFacetGroupKey].faceting_handler
        facetingHandler.toggleKeySelection(testFacetKey)
        esList.setMeta('facets_changed', true)
        esList.fetch(options=undefined, testMode=true)

      it 'Updates the request data as the pagination moves', ->

        totalRecords = 100
        esList.setMeta('total_records', totalRecords)
        pageSize = 10
        esList.setMeta('page_size', pageSize)
        totalPages = Math.ceil(totalRecords / pageSize)
        esList.setMeta('total_pages', totalPages)

        testIteratesPages(esList, pageSize, totalPages)

        facetGroups = esList.getFacetsGroups()
        testFacetGroupKey = 'max_phase'
        testFacetKey = facetGroups[testFacetGroupKey].faceting_handler.faceting_keys_inorder[0]
        expect(facetGroups[testFacetGroupKey].faceting_handler.faceting_data[testFacetKey].selected).toBe(true)

      it 'updates the request data as the pagination moves, with different pager sizes', ->

        totalRecords = 100
        testIteratesPagesWithDifferentPageSizes(esList, totalRecords)

    describe 'After selecting multiple facets', ->

      beforeAll ->

        esList = glados.models.paginatedCollections.PaginatedCollectionFactory.getAllESResultsListDict()[\
        glados.models.paginatedCollections.Settings.ES_INDEXES.COMPOUND.KEY_NAME
        ]

      testFacetGroupKey1 = 'max_phase'
      testFacetGroupKey2 = 'molecule_properties.num_ro5_violations'

      facetsStateMustBe =
        selected:
          max_phase: ["0"]
          'molecule_properties.num_ro5_violations': ["0"]

      beforeEach ->

        esList.setMeta('esSearchQuery', esSearchQuery)
        facetGroups = esList.getFacetsGroups()

        testFacetKey1 = facetGroups[testFacetGroupKey1].faceting_handler.faceting_keys_inorder[0]
        facetingHandler = facetGroups[testFacetGroupKey1].faceting_handler
        facetingHandler.toggleKeySelection(testFacetKey1)

        testFacetKey2 = facetGroups[testFacetGroupKey2].faceting_handler.faceting_keys_inorder[0]
        facetingHandler = facetGroups[testFacetGroupKey2].faceting_handler
        facetingHandler.toggleKeySelection(testFacetKey2)

        esList.setMeta('facets_changed', true)
        esList.fetch(options=undefined, testMode=true)

      it 'generates a state object', ->  TestsUtils.testSavesList(esList,
        pathInSettingsMustBe='ES_INDEXES.COMPOUND',
        queryStringMustBe=undefined,
        useQueryStringMustBe=undefined,
        stickyQueryMustBe=undefined,
        esSearchQueryMustBe= esSearchQuery,
        searchTermMustBe=undefined,
        contextualColumnsMustBe=undefined,
        generatorListMustBe=undefined,
        facetsStateMustBe
      )


