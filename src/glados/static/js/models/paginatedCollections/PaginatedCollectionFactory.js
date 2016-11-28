// Generated by CoffeeScript 1.4.0

glados.useNameSpace('glados.models.paginatedCollections', {
  PaginatedCollectionFactory: {
    getNewESResultsListFor: function(esIndexSettings) {
      var indexESPagQueryCollection;
      indexESPagQueryCollection = glados.models.paginatedCollections.ESPaginatedQueryCollection.extend({
        model: esIndexSettings.MODEL,
        initialize: function() {
          return this.meta = {
            index: esIndexSettings.PATH,
            page_size: Settings.CARD_PAGE_SIZES[0],
            available_page_sizes: Settings.CARD_PAGE_SIZES,
            current_page: 1,
            to_show: [],
            columns: esIndexSettings.COLUMNS
          };
        }
      });
      return new indexESPagQueryCollection;
    },
    getNewWSCollectionFor: function(collectionSettings) {
      var wsPagCollection;
      wsPagCollection = glados.models.paginatedCollections.WSPaginatedCollection.extend({
        model: collectionSettings.MODEL,
        initialize: function() {
          this.meta = {
            base_url: collectionSettings.BASE_URL,
            page_size: collectionSettings.DEFAULT_PAGE_SIZE,
            available_page_sizes: collectionSettings.AVAILABLE_PAGE_SIZES,
            current_page: 1,
            to_show: [],
            columns: collectionSettings.COLUMNS
          };
          return this.initialiseUrl();
        }
      });
      return new wsPagCollection;
    },
    getNewCompoundResultsList: function() {
      return this.getNewESResultsListFor(glados.models.paginatedCollections.Settings.ES_INDEXES.COMPOUND);
    },
    getNewDocumentResultsList: function() {
      return this.getNewESResultsListFor(glados.models.paginatedCollections.Settings.ES_INDEXES.DOCUMENT);
    },
    getNewDrugList: function() {
      var list;
      list = this.getNewWSCollectionFor(glados.models.paginatedCollections.Settings.WS_COLLECTIONS.DRUG_LIST);
      list.parse = function(data) {
        data.page_meta.records_in_page = data.molecules.length;
        this.resetMeta(data.page_meta);
        return data.molecules;
      };
      return list;
    },
    getNewDocumentsFromTermsList: function() {
      var list;
      list = this.getNewWSCollectionFor(glados.models.paginatedCollections.Settings.WS_COLLECTIONS.DOCS_BY_TERM_LIST);
      list.initUrl = function(term) {
        this.baseUrl = Settings.WS_BASE_URL + 'document_term.json?term_text=' + term + '&order_by=-score';
        this.setMeta('base_url', this.baseUrl, true);
        return this.initialiseUrl();
      };
      list.fetch = function() {
        var checkAllInfoReady, documents, getDocuments, receivedDocs, thisCollection, totalDocs, url;
        this.reset();
        url = this.getPaginatedURL();
        documents = [];
        totalDocs = 0;
        receivedDocs = 0;
        getDocuments = $.getJSON(url);
        thisCollection = this;
        checkAllInfoReady = function() {
          if (receivedDocs === totalDocs) {
            console.log('ALL READY!');
            console.log(thisCollection);
            return thisCollection.trigger('do-repaint');
          }
        };
        getDocuments.done(function(data) {
          var doc, docInfo, _i, _len, _results;
          data.page_meta.records_in_page = data.document_terms.length;
          thisCollection.resetMeta(data.page_meta);
          documents = data.document_terms;
          totalDocs = documents.length;
          _results = [];
          for (_i = 0, _len = documents.length; _i < _len; _i++) {
            docInfo = documents[_i];
            doc = new Document(docInfo);
            thisCollection.add(doc);
            _results.push(doc.fetch({
              success: function() {
                receivedDocs += 1;
                return checkAllInfoReady();
              }
            }));
          }
          return _results;
        });
        return getDocuments.fail(function() {
          return console.log('ERROR!');
        });
      };
      return list;
    }
  }
});
