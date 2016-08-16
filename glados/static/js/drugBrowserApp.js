// Generated by CoffeeScript 1.4.0
var DrugBrowserApp;

DrugBrowserApp = (function() {

  function DrugBrowserApp() {}

  DrugBrowserApp.initDrugList = function() {
    var drugList;
    drugList = new DrugList;
    drugList.url = 'https://www.ebi.ac.uk/chembl/api/data/molecule.json?max_phase=4';
    return drugList;
  };

  DrugBrowserApp.initBrowserAsTable = function(col, top_level_elem) {
    var asTableView;
    asTableView = new DrugBrowserTableView({
      collection: col,
      el: top_level_elem
    });
    return asTableView;
  };

  DrugBrowserApp.initInfinityBrowserView = function(top_level_elem) {
    var infView;
    infView = new DrugBrowserInfinityView({
      el: top_level_elem
    });
    return infView;
  };

  return DrugBrowserApp;

})();
