class SearchResultsApp

  # --------------------------------------------------------------------------------------------------------------------
  # Initialization
  # --------------------------------------------------------------------------------------------------------------------

  @init = ->
    @eSQueryExplainView = glados.views.SearchResults.ESQueryExplainView.getInstance()
    @searchBarView = glados.views.SearchResults.SearchBarView.getInstance()
    @searchBarAutocompleteView = glados.views.SearchResults.SearchBarAutocompleteView.getInstance()

    $searchResultsContainer = $('.BCK-SearchResultsContainer')
    new glados.views.SearchResults.SearchResultsView
      el: $searchResultsContainer
      model: SearchModel.getInstance()

  # --------------------------------------------------------------------------------------------------------------------
  # Views
  # --------------------------------------------------------------------------------------------------------------------

  @initSubstructureSearchResults = () ->
    GlobalVariables.SEARCH_TERM = URLProcessor.getSubstructureSearchQueryString()
    resultsList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewSubstructureSearchResultsList()
    resultsList.initURL GlobalVariables.SEARCH_TERM

    queryParams =
      search_term: GlobalVariables.SEARCH_TERM

    $queryContainer = $('.BCK-query-Container')
    new glados.views.SearchResults.StructureQueryView
      el: $queryContainer
      query_params: queryParams

    $progressElement = $('#BCK-loading-messages-container')
    $browserContainer = $('.BCK-BrowserContainer')
    @initBrowserFromWSResults(resultsList, $browserContainer, $progressElement)

  @initSimilaritySearchResults = () ->
    GlobalVariables.SEARCH_TERM = URLProcessor.getSimilaritySearchQueryString()
    GlobalVariables.SIMILARITY_PERCENTAGE = URLProcessor.getSimilaritySearchPercentage()
    console.log 'initSimilaritySearchResults'
    queryParams =
      search_term: GlobalVariables.SEARCH_TERM
      similarity_percentage: GlobalVariables.SIMILARITY_PERCENTAGE

    $queryContainer = $('.BCK-query-Container')
    new glados.views.SearchResults.StructureQueryView
      el: $queryContainer
      query_params: queryParams

    resultsList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewSimilaritySearchResultsList()
    resultsList.initURL GlobalVariables.SEARCH_TERM, GlobalVariables.SIMILARITY_PERCENTAGE

    $progressElement = $('#BCK-loading-messages-container')
    $browserContainer = $('.BCK-BrowserContainer')
    @initBrowserFromWSResults(resultsList, $browserContainer, $progressElement, [Compound.COLUMNS.SIMILARITY_ELASTIC],
    glados.models.paginatedCollections.Settings.ES_INDEXES_NO_MAIN_SEARCH.COMPOUND_SIMILARITY_MAPS)

  @initFlexmatchSearchResults = () ->
    GlobalVariables.SEARCH_TERM = URLProcessor.getUrlPartInReversePosition(0)

    queryParams =
      search_term: GlobalVariables.SEARCH_TERM

    $queryContainer = $('.BCK-query-Container')
    new glados.views.SearchResults.StructureQueryView
      el: $queryContainer
      query_params: queryParams

    resultsList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewFlexmatchSearchResultsList()
    resultsList.initURL GlobalVariables.SEARCH_TERM

    $progressElement = $('#BCK-loading-messages-container')
    $browserContainer = $('.BCK-BrowserContainer')
    @initBrowserFromWSResults(resultsList, $browserContainer, $progressElement)

  @initBrowserFromWSResults = (resultsList, $browserContainer, $progressElement, contextualColumns, customSettings) ->

    deferreds = resultsList.getAllResults($progressElement)

    # for now, we need to jump from web services to elastic
    $.when.apply($, deferreds).done(->


      esCompoundsList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESCompoundsList(undefined,
        resultsList.allResults, contextualColumns, customSettings)

      new glados.views.Browsers.BrowserMenuView
        collection: esCompoundsList
        el: $browserContainer

      esCompoundsList.fetch()

    ).fail((msg) ->

        $browserContainer.hide()
        if $progressElement?
          # it can be a jqxr
          if msg.status?
            $progressElement.html glados.Utils.ErrorMessages.getCollectionErrorContent(msg)
          else
            $progressElement.html Handlebars.compile($('#Handlebars-Common-CollectionErrorMsg').html())
              msg: msg
      )

