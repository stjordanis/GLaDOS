// Generated by CoffeeScript 1.4.0
var PaginatedViewExt;

PaginatedViewExt = {
  events: {
    'click .page-selector': 'getPageEvent',
    'change .change-page-size': 'changePageSize',
    'click .sort': 'sortCollection',
    'input .search': 'setSearch',
    'change .select-sort': 'sortCollectionFormSelect',
    'click .btn-sort-direction': 'changeSortOrderInf'
  },
  fill_template: function(elem_id) {
    var $append_to, $elem, $item_template, columns_val, header_row_cont, header_template, img_url, item, new_item_cont, _i, _len, _ref, _results;
    $elem = $(this.el).find('#' + elem_id);
    $item_template = $('#' + $elem.attr('data-hb-template'));
    $append_to = $elem;
    if ($elem.is('table')) {
      header_template = $('#' + $elem.attr('data-hb-template-2'));
      header_row_cont = Handlebars.compile(header_template.html())({
        columns: this.collection.getMeta('columns')
      });
      $elem.append($(header_row_cont));
      $elem.append($('<tbody>'));
    }
    _ref = this.collection.getCurrentPage();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      img_url = '';
      columns_val = this.collection.getMeta('columns').map(function(col) {
        col['value'] = item.get(col.comparator);
        col['has_link'] = col.link_base != null;
        if (!!col['has_link']) {
          col['link_url'] = col['link_base'].replace('$$$', col['value']);
        }
        if (col['image_base_url'] != null) {
          return img_url = col['image_base_url'].replace('$$$', col['value']);
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
  fillPaginator: function(elem_id) {
    var current_page, elem, first_page_to_show, first_record, last_page, last_page_to_show, num, num_pages, page_size, pages, records_in_page, show_next_ellipsis, show_previous_ellipsis, template;
    elem = $(this.el).find('#' + elem_id);
    template = $('#' + elem.attr('data-hb-template'));
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
    elem.html(Handlebars.compile(template.html())({
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
    return $elem.html(Handlebars.compile($template.html())({
      num_results: this.collection.getMeta('total_records')
    }));
  },
  getPageEvent: function(event) {
    var clicked, pageNum;
    clicked = $(event.currentTarget);
    if (clicked.hasClass('disabled')) {
      return;
    }
    if (this.collection.getMeta('server_side') === true) {
      this.showPreloader();
    }
    pageNum = clicked.attr('data-page');
    return this.requestPageInCollection(pageNum);
  },
  requestPageInCollection: function(pageNum) {
    var current_page;
    current_page = this.collection.getMeta('current_page');
    if (current_page === pageNum) {
      return;
    }
    if (!!this.isInfinite) {
      this.showInfiniteBrPreolader();
    }
    if (pageNum === "previous") {
      pageNum = current_page - 1;
    } else if (pageNum === "next") {
      pageNum = current_page + 1;
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
      this.showPreloader();
    }
    selector = $(event.currentTarget);
    new_page_size = selector.val();
    return this.collection.resetPageSize(new_page_size);
  },
  setSearch: function(event) {
    var $searchInput, column, term;
    $searchInput = $(event.currentTarget);
    term = $searchInput.val();
    column = $searchInput.attr('data-column');
    if (this.isInfinite) {
      this.clearInfiniteContainer();
      this.showInfiniteBrPreolader();
    }
    return this.collection.setSearch(term, column);
  },
  sortCollection: function(event) {
    var comparator, order_icon;
    if (this.collection.getMeta('server_side') === true) {
      this.showPreloader();
    }
    order_icon = $(event.currentTarget);
    comparator = order_icon.attr('data-comparator');
    return this.triggerCollectionSort(comparator);
  },
  triggerCollectionSort: function(comparator) {
    if (this.isInfinite) {
      this.clearInfiniteContainer();
      this.showInfiniteBrPreolader();
    }
    return this.collection.sortCollection(comparator);
  },
  activatePageSelector: function() {
    return $(this.el).find('select').material_select();
  },
  showVisibleContent: function() {
    $(this.el).children('.card-preolader-to-hide').hide();
    return $(this.el).children(':not(.card-preolader-to-hide, .card-load-error, .modal)').show();
  },
  showPreloader: function() {
    $(this.el).children('.card-preolader-to-hide').show();
    return $(this.el).children(':not(.card-preolader-to-hide)').hide();
  },
  showControls: function() {
    return $(this.el).find('.controls').removeClass('hide');
  },
  hideInfiniteBrPreolader: function() {
    console.log('hiding preloader');
    return $(this.el).children('.infinite-browse-preloader').hide();
  },
  showInfiniteBrPreolader: function() {
    console.log('showing preloader');
    return $(this.el).children('.infinite-browse-preloader').show();
  },
  setUpLoadingWaypoint: function() {
    var advancer, cards, middleCard, waypoint;
    cards = $('#DrugInfBrowserCardsContainer').children();
    middleCard = cards[Math.round(cards.length / 2)];
    advancer = $.proxy(function() {
      return this.requestPageInCollection('next');
    }, this);
    return waypoint = new Waypoint({
      element: middleCard,
      handler: function(direction) {
        if (direction === 'down') {
          return advancer();
        }
      }
    });
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
  clearInfiniteContainer: function() {
    return $('#' + this.containerID).empty();
  },
  sortCollectionFormSelect: function(event) {
    var comparator, selector;
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
  }
};
