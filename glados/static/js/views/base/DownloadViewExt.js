// Generated by CoffeeScript 1.4.0
var DownloadViewExt;

DownloadViewExt = {
  events: {
    'click .BCK-trigger-download-JSON': 'triggerDownloadJSON',
    'click .BCK-trigger-download-CSV': 'triggerDownloadCSV',
    'click .BCK-trigger-download-XLS': 'triggerDownloadXLS'
  },
  showDownloadOptions: function() {
    return console.log('show options');
  },
  triggerDownloadJSON: function() {
    this.modelOrCollection = this.model != null ? this.model : this.collection;
    return this.modelOrCollection.downloadJSON(this.getFilename('json'), this.downloadParserFunction);
  },
  triggerDownloadCSV: function() {
    this.modelOrCollection = this.model != null ? this.model : this.collection;
    return this.modelOrCollection.downloadCSV(this.getFilename('csv'), this.downloadParserFunction);
  },
  triggerDownloadXLS: function() {
    this.modelOrCollection = this.model != null ? this.model : this.collection;
    return this.modelOrCollection.downloadXLS(this.getFilename('xlsx'), this.downloadParserFunction);
  },
  getFilename: function(format) {
    return 'file.txt';
  }
};
