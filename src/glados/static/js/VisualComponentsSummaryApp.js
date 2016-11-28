// Generated by CoffeeScript 1.4.0
var VisualComponentsSummaryApp;

VisualComponentsSummaryApp = (function() {

  function VisualComponentsSummaryApp() {}

  VisualComponentsSummaryApp.init = function() {
    var compResListAsCardView, documentAssayNetwork, sampleCompound, sampleDrugList;
    sampleCompound = new Compound({
      molecule_chembl_id: 'CHEMBL1163143'
    });
    VisualComponentsSummaryApp.sampleCompound = sampleCompound;
    VisualComponentsSummaryApp.initSampleCompound3DView($('#BCK-compound-3dview'));
    sampleCompound.fetch();
    documentAssayNetwork = new DocumentAssayNetwork({
      document_chembl_id: 'CHEMBL1151960'
    });
    VisualComponentsSummaryApp.sampleDocumentAssayNetwork = documentAssayNetwork;
    VisualComponentsSummaryApp.initSampleDANView($('#DAssayNetworkCard'));
    documentAssayNetwork.fetch();
    sampleDrugList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewDrugList();
    VisualComponentsSummaryApp.sampleDrugList = sampleDrugList;
    VisualComponentsSummaryApp.initSampleBrowserAsTableInCardView($('#BCK-BrowserAsTable'));
    sampleDrugList.fetch({
      reset: true
    });
    return compResListAsCardView = VisualComponentsSummaryApp.initCSampleBrowserAsCPinCardView($('#BCK-ResultsCardPages'));
  };

  VisualComponentsSummaryApp.initSampleCompound3DView = function($elem) {
    var comp3DView;
    return comp3DView = new Compound3DViewSpeck({
      el: $elem,
      model: VisualComponentsSummaryApp.sampleCompound,
      type: 'reduced'
    });
  };

  VisualComponentsSummaryApp.initSampleDANView = function($elem) {
    var danView;
    danView = new DocumentAssayNetworkView({
      el: $elem,
      model: VisualComponentsSummaryApp.sampleDocumentAssayNetwork
    });
    return danView;
  };

  VisualComponentsSummaryApp.initSampleBrowserAsTableInCardView = function($elem) {
    var asTableInCardView;
    asTableInCardView = new DrugBrowserTableAsCardView({
      collection: VisualComponentsSummaryApp.sampleDrugList,
      el: $elem
    });
    return asTableInCardView;
  };

  VisualComponentsSummaryApp.initCSampleBrowserAsCPinCardView = function($elem) {
    var view;
    view = new CompoundResultsListAsCardView({
      collection: VisualComponentsSummaryApp.sampleDrugList,
      el: $elem
    });
    return view;
  };

  return VisualComponentsSummaryApp;

})();
