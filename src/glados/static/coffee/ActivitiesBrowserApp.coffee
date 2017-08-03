class ActivitiesBrowserApp

  @init = ->

    filter = URLProcessor.getFilter()
    actsList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESActivitiesList(filter)

    $browserContainer = $('.BCK-BrowserContainer')
    new glados.views.Browsers.BrowserMenuView
      collection: actsList
      el: $browserContainer

    new glados.views.Browsers.BrowserFacetView
      collection: actsList
      el: $browserContainer.find('.BCK-Facets-Container')

    actsList.fetch()

  @initMatrixCellMiniReportCard: ($containerElem, d, compoundsAreRows=true) ->

    summary = new glados.models.Activity.ActivityAggregation
      activity_count: d.activity_count
      pchembl_value_avg: d.pchembl_value_avg
      molecule_chembl_id: if compoundsAreRows then d.row_id else d.col_id
      target_chembl_id: if compoundsAreRows then d.col_id else d.row_id
      pchembl_value_max: d.pchembl_value_max

    new glados.views.Activity.ActivityAggregationView
      el: $containerElem
      model: summary