// Generated by CoffeeScript 1.4.0
var PaginatedViewExt;

PaginatedViewExt = {
  events: {
    'click .page-selector': 'getPageEvent',
    'change .change-page-size': 'changePageSize',
    'click .sort': 'sortCollection',
    'input .search': 'setSearch',
    'change select.select-search': 'setSearch',
    'change .select-sort': 'sortCollectionFormSelect',
    'click .btn-sort-direction': 'changeSortOrderInf'
  },
  fillTemplates: function() {
    var $elem, i, _i, _ref, _results;
    $elem = $(this.el).find('.BCK-items-container');
    _results = [];
    for (i = _i = 0, _ref = $elem.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      _results.push(this.sendDataToTemplate($($elem[i])));
    }
    return _results;
  },
  sendDataToTemplate: function($specificElem) {
    var $append_to, $item_template, columnsWithValues, header_row_cont, header_template, img_url, item, new_item_cont, _i, _len, _ref, _results;
    $item_template = $('#' + $specificElem.attr('data-hb-template'));
    $append_to = $specificElem;
    if ($specificElem.is('table')) {
      header_template = $('#' + $specificElem.attr('data-hb-header-template'));
      header_row_cont = Handlebars.compile(header_template.html())({
        columns: this.collection.getMeta('columns')
      });
      $specificElem.append($(header_row_cont));
      $specificElem.append($('<tbody>'));
    }
    _ref = this.collection.getCurrentPage();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      img_url = '';
      columnsWithValues = this.collection.getMeta('columns').map(function(col) {
        col['value'] = item.get(col.comparator);
        col['has_link'] = col.link_base != null;
        if (!!col['has_link']) {
          col['link_url'] = col['link_base'].replace('$$$', col['value']);
        }
        if (col['image_base_url'] != null) {
          img_url = col['image_base_url'].replace('$$$', col['value']);
        }
        if (col['custom_field_template'] != null) {
          return col['custom_html'] = Handlebars.compile(col['custom_field_template'])({
            val: col['value']
          });
        }
      });
      new_item_cont = Handlebars.compile($item_template.html())({
        img_url: img_url,
        columns: this.collection.getMeta('columns')
      });
      _results.push($append_to.append($(new_item_cont)));
    }
    return _results;
  },
  fillPaginators: function() {
    var $elem, current_page, first_page_to_show, first_record, last_page, last_page_to_show, num, num_pages, page_size, pages, records_in_page, show_next_ellipsis, show_previous_ellipsis, template;
    $elem = $(this.el).find('.BCK-paginator-container');
    template = $('#' + $elem.attr('data-hb-template'));
    current_page = this.collection.getMeta('current_page');
    records_in_page = this.collection.getMeta('records_in_page');
    page_size = this.collection.getMeta('page_size');
    num_pages = this.collection.getMeta('total_pages');
    first_record = (current_page - 1) * page_size;
    last_page = first_record + records_in_page;
    show_previous_ellipsis = false;
    show_next_ellipsis = false;
    if (num_pages <= 5) {
      first_page_to_show = 1;
      last_page_to_show = num_pages;
    } else if (current_page + 2 <= 5) {
      first_page_to_show = 1;
      last_page_to_show = 5;
      show_next_ellipsis = true;
    } else if (current_page + 2 < num_pages) {
      first_page_to_show = current_page - 2;
      last_page_to_show = current_page + 2;
      show_previous_ellipsis = true;
      show_next_ellipsis = true;
    } else {
      first_page_to_show = num_pages - 4;
      last_page_to_show = num_pages;
      show_previous_ellipsis = true;
    }
    pages = (function() {
      var _i, _results;
      _results = [];
      for (num = _i = first_page_to_show; first_page_to_show <= last_page_to_show ? _i <= last_page_to_show : _i >= last_page_to_show; num = first_page_to_show <= last_page_to_show ? ++_i : --_i) {
        _results.push(num);
      }
      return _results;
    })();
    $elem.html(Handlebars.compile(template.html())({
      pages: pages,
      records_showing: first_record + '-' + last_page,
      total_records: this.collection.getMeta('total_records'),
      show_next_ellipsis: show_next_ellipsis,
      show_previous_ellipsis: show_previous_ellipsis
    }));
    this.activateCurrentPageButton();
    return this.enableDisableNextLastButtons();
  },
  fillNumResults: function() {
    var $elem, $template;
    $elem = $(this.el).find('.num-results');
    $template = $('#' + $elem.attr('data-hb-template'));
    $elem.html(Handlebars.compile($template.html())({
      num_results: this.collection.getMeta('total_records')
    }));
    return console.log(this.collection.getMeta('total_records'));
  },
  getPageEvent: function(event) {
    var clicked, pageNum;
    clicked = $(event.currentTarget);
    if (clicked.hasClass('disabled')) {
      return;
    }
    if (this.collection.getMeta('server_side') === true) {
      this.showPaginatedViewPreloader();
    }
    pageNum = clicked.attr('data-page');
    return this.requestPageInCollection(pageNum);
  },
  requestPageInCollection: function(pageNum) {
    var currentPage, totalPages;
    currentPage = this.collection.getMeta('current_page');
    totalPages = this.collection.getMeta('total_pages');
    if (pageNum === "previous") {
      pageNum = currentPage - 1;
    } else if (pageNum === "next") {
      pageNum = currentPage + 1;
    }
    if (pageNum > totalPages) {
      return;
    }
    return this.collection.setPage(pageNum);
  },
  enableDisableNextLastButtons: function() {
    var current_page, total_pages;
    current_page = parseInt(this.collection.getMeta('current_page'));
    total_pages = parseInt(this.collection.getMeta('total_pages'));
    if (current_page === 1) {
      $(this.el).find("[data-page='previous']").addClass('disabled');
    } else {
      $(this.el).find("[data-page='previous']").removeClass('disabled');
    }
    if (current_page === total_pages) {
      return $(this.el).find("[data-page='next']").addClass('disabled');
    } else {
      return $(this.el).find("[data-page='next']").removeClass('disabled');
    }
  },
  activateCurrentPageButton: function() {
    var current_page;
    current_page = this.collection.getMeta('current_page');
    $(this.el).find('.page-selector').removeClass('active');
    return $(this.el).find("[data-page=" + current_page + "]").addClass('active');
  },
  changePageSize: function(event) {
    var new_page_size, selector;
    if (this.collection.getMeta('server_side') === true) {
      this.showPaginatedViewPreloader();
    }
    selector = $(event.currentTarget);
    new_page_size = selector.val();
    return this.collection.resetPageSize(new_page_size);
  },
  setSearch: _.debounce(function(event) {
    var $searchInput, column, term, type;
    $searchInput = $(event.currentTarget);
    term = $searchInput.val();
    column = $searchInput.attr('data-column');
    type = $searchInput.attr('data-column-type');
    return this.triggerSearch(term, column, type);
  }, Settings['SEARCH_INPUT_DEBOUNCE_TIME']),
  setNumericSearchWrapper: function($elem) {
    var ctx, setNumericSearch;
    ctx = this;
    setNumericSearch = _.debounce(function(values, handle) {
      var column, term, type;
      term = values.join(',');
      column = $elem.attr('data-column');
      type = $elem.attr('data-column-type');
      return ctx.triggerSearch(term, column, type);
    }, Settings['SEARCH_INPUT_DEBOUNCE_TIME']);
    return setNumericSearch;
  },
  triggerSearch: function(term, column, type) {
    this.clearContentContainer();
    this.showPaginatedViewPreloader();
    return this.collection.setSearch(term, column, type);
  },
  sortCollection: function(event) {
    var comparator, order_icon;
    if (this.collection.getMeta('server_side') === true) {
      this.showPaginatedViewPreloader();
    }
    order_icon = $(event.currentTarget);
    comparator = order_icon.attr('data-comparator');
    return this.triggerCollectionSort(comparator);
  },
  triggerCollectionSort: function(comparator) {
    this.clearContentContainer();
    this.showPaginatedViewPreloader();
    return this.collection.sortCollection(comparator);
  },
  showPaginatedViewContent: function() {
    var $contentCont, $preloaderCont;
    $preloaderCont = $(this.el).find('.BCK-PreoladerContainer');
    $contentCont = $(this.el).find('.BCK-items-container');
    $preloaderCont.hide();
    return $contentCont.show();
  },
  showPaginatedViewPreloader: function() {
    var $contentCont, $preloaderCont;
    $preloaderCont = $(this.el).find('.BCK-PreoladerContainer');
    $contentCont = $(this.el).find('.BCK-items-container');
    $preloaderCont.show();
    return $contentCont.hide();
  },
  showPaginatedViewPreloaderAndContent: function() {
    var $contentCont, $preloaderCont;
    $preloaderCont = $(this.el).find('.BCK-PreoladerContainer');
    $contentCont = $(this.el).find('.BCK-items-container');
    $preloaderCont.show();
    return $contentCont.show();
  },
  clearContentContainer: function() {
    return $(this.el).find('.BCK-items-container').empty();
  },
  hidePreloaderOnly: function() {
    var $preloaderCont;
    $preloaderCont = $(this.el).find('.BCK-PreoladerContainer');
    return $preloaderCont.hide();
  },
  showControls: function() {
    return $(this.el).find('.controls').removeClass('hide');
  },
  showNumResults: function() {
    return $(this.el).children('.num-results').show();
  },
  hideNumResults: function() {
    return $(this.el).children('.num-results').hide();
  },
  setUpLoadingWaypoint: function() {
    var $cards, $middleCard, advancer, waypoint;
    $cards = $('.BCK-items-container').children();
    if ($cards.length === 0) {
      return;
    }
    $middleCard = $cards[Math.floor($cards.length / 2)];
    advancer = $.proxy(function() {
      Waypoint.destroyAll();
      if (this.collection.currentlyOnLastPage()) {
        return;
      }
      this.showPaginatedViewPreloaderAndContent();
      return this.requestPageInCollection('next');
    }, this);
    Waypoint.destroyAll();
    return waypoint = new Waypoint({
      element: $middleCard,
      handler: function(direction) {
        if (direction === 'down') {
          return advancer();
        }
      }
    });
  },
  hidePreloaderIfNoNextItems: function() {
    if (this.collection.currentlyOnLastPage()) {
      return this.hidePreloaderOnly();
    }
  },
  renderSortingSelector: function() {
    var $btnSortDirectionContainer, $selectSortContainer, $template, col_comparators, columns, currentProps, currentSortDirection, one_selected, sortClassAndText;
    $selectSortContainer = $(this.el).find('.select-sort-container');
    $selectSortContainer.empty();
    $template = $('#' + $selectSortContainer.attr('data-hb-template'));
    columns = this.collection.getMeta('columns');
    col_comparators = _.map(columns, function(col) {
      return {
        comparator: col.comparator,
        selected: col.is_sorting !== 0
      };
    });
    one_selected = _.reduce(col_comparators, (function(a, b) {
      return a.selected || b.selected;
    }), 0);
    $selectSortContainer.html(Handlebars.compile($template.html())({
      columns: col_comparators,
      one_selected: one_selected
    }));
    $btnSortDirectionContainer = $(this.el).find('.btn-sort-direction-container');
    $btnSortDirectionContainer.empty();
    $template = $('#' + $btnSortDirectionContainer.attr('data-hb-template'));
    sortClassAndText = {
      '-1': {
        sort_class: 'fa-sort-desc',
        text: 'Desc'
      },
      '0': {
        sort_class: 'fa-sort',
        text: ''
      },
      '1': {
        sort_class: 'fa-sort-asc',
        text: 'Asc'
      }
    };
    currentSortDirection = _.reduce(_.pluck(columns, 'is_sorting'), (function(a, b) {
      return a + b;
    }), 0);
    currentProps = sortClassAndText[currentSortDirection.toString()];
    return $btnSortDirectionContainer.html(Handlebars.compile($template.html())({
      sort_class: currentProps.sort_class,
      text: currentProps.text,
      disabled: currentSortDirection === 0
    }));
  },
  sortCollectionFormSelect: function(event) {
    var comparator, selector;
    this.showPaginatedViewPreloader();
    selector = $(event.currentTarget);
    comparator = selector.val();
    if (comparator === '') {
      return;
    }
    return this.triggerCollectionSort(comparator);
  },
  changeSortOrderInf: function() {
    var comp;
    comp = this.collection.getCurrentSortingComparator();
    if (comp != null) {
      return this.triggerCollectionSort(comp);
    }
  },
  fillPageSelectors: function() {
    var $contentTemplate, $elem, currentPageSize, item, pageSizesItems, size, _i, _len, _ref;
    $elem = $(this.el).find('.BCK-select-page-size-container');
    $contentTemplate = $('#' + $elem.attr('data-hb-template'));
    currentPageSize = this.collection.getMeta('page_size');
    pageSizesItems = [];
    _ref = this.collection.getMeta('available_page_sizes');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      size = _ref[_i];
      item = {};
      item.number = size;
      item.is_selected = currentPageSize === size;
      pageSizesItems.push(item);
    }
    return $elem.html(Handlebars.compile($contentTemplate.html())({
      items: pageSizesItems
    }));
  },
  activateSelectors: function() {
    return $(this.el).find('select').material_select();
  }
};
