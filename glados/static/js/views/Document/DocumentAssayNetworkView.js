// Generated by CoffeeScript 1.4.0
var DocumentAssayNetworkView;

DocumentAssayNetworkView = CardView.extend(ResponsiviseViewExt).extend(DANViewExt).extend(DownloadViewExt).extend({
  initialize: function() {
    var updateViewProxy;
    this.$vis_elem = $('#AssayNetworkVisualisationContainer');
    updateViewProxy = this.setUpResponsiveRender();
    this.model.on('change', updateViewProxy, this);
    this.csvFilename = this.model.get('document_chembl_id') + 'DocumentAssayNetwork.csv';
    return this.jsonFilename = this.model.get('document_chembl_id') + 'DocumentAssayNetwork.json';
  },
  render: function() {
    console.log('render!');
    this.hidePreloader();
    this.addFSLinkAndInfo();
    return this.paintMatrix();
  },
  addFSLinkAndInfo: function() {
    $(this.el).find('.fullscreen-link').html(Handlebars.compile($('#Handlebars-Document-DAN-FullScreenLink').html())({
      chembl_id: this.model.get('document_chembl_id')
    }));
    return $(this.el).find('.num-results').html(Handlebars.compile($('#Handlebars-Document-DAN-NumResults').html())({
      num_results: this.model.get('graph').nodes.length
    }));
  }
});
