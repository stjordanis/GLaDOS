glados.useNameSpace 'glados.models.Target',
  TargetAssociatedCompounds: Backbone.Model.extend

    INITIAL_STATE: 'INITIAL_STATE'
    LOADING_MIN_MAX: 'LOADING_MIN_MAX'
    LOADING_BUCKETS: 'LOADING_BUCKETS'

    initialize: ->

      @url = glados.models.paginatedCollections.Settings.ES_BASE_URL + '/chembl_molecule/_search'
      @set('state', @INITIAL_STATE, {silent:true})

    fetch: ->
      console.log 'FETCHING!'
      $progressElem = @get('progress_elem')
      state = @get('state')

      if not @get('min_value')? or not @get('max_value')?
        if $progressElem?
          $progressElem.html 'Loading minimun and maximum values...'
        @set('state', @LOADING_MIN_MAX, {silent:true})
        console.log 'GOING TO FETCH MIN MAX'
        @fetchMinMax()
        return


      console.log 'ALREADY GOT MIN MAX'
      if $progressElem?
          $progressElem.html 'Fetching Compound Data...'

      return
      @set(@parse())

    fetchMinMax: ->

      $progressElem = @get('progress_elem')

      console.log 'FETCHING MIN MAX'
      esJSONRequest = JSON.stringify(@getRequestMinMaxData())

      fetchESOptions =
        url: @url
        data: esJSONRequest
        type: 'POST'
        reset: true

      thisModel = @
      $.ajax(fetchESOptions).done((data) ->
        thisModel.set(thisModel.parseMinMax(data), {silent:true})
        thisModel.set('state', @LOADING_BUCKETS, {silent:true})
        console.log 'GOT MIN AND MAX'
        thisModel.fetch()
      ).fail( glados.Utils.ErrorMessages.showLoadingErrorMessageGen($progressElem))


    parse: (data) ->

      buckets = [
        {"key":"0","doc_count":94,"link":"/activities/filter/target_chembl_id:CHEMBL2111342 AND standard_type:\"Ratio\""},
        {"key":"50","doc_count":32,"link":"/activities/filter/target_chembl_id:CHEMBL2111342 AND standard_type:\"Ki\""},
        {"key":"100","doc_count":18,"link":"/activities/filter/target_chembl_id:CHEMBL2111342 AND standard_type:\"IC50\""},
        {"key":"150","doc_count":5,"link":"/activities/filter/target_chembl_id:CHEMBL2111342 AND standard_type:\"EC50\""},
        {"key":"200","doc_count":5,"link":"/activities/filter/target_chembl_id:CHEMBL2111342 AND standard_type:\"Emax\""},
        {"key":"250","doc_count":4,"link":"/activities/filter/target_chembl_id:CHEMBL2111342 AND standard_type:\"Change\""},
        {"key":"300","doc_count":2,"link":"/activities/filter/target_chembl_id:CHEMBL2111342 AND standard_type:\"Bmax\""},
        {"key":"350","doc_count":2,"link":"/activities/filter/target_chembl_id:CHEMBL2111342 AND standard_type:\"Kd\""}
      ]

      return {
        'buckets': buckets
      }

    getRequestData: ->

      xaxisProperty = @get('current_xaxis_property')
      interval = Math.ceil((@get('max_value') - @get('min_value')) / @get('num_columns')) + 1

      return {
        size: 0,
        query:
          query_string:
            "analyze_wildcard": true,
            "query": "*"
        aggs:
          x_axis_agg:
            histogram:
              field: xaxisProperty,
              interval: interval,
              min_doc_count: 1
      }

    getRequestMinMaxData: ->

      return {
        size: 0,
        query:
          query_string:
            analyze_wildcard: true,
            query: "*"
        aggs:
          min_agg:
            min:
              field: @get('current_xaxis_property')
          max_agg:
            max:
              field: @get('current_xaxis_property')
      }

    parseMinMax: (data) ->
      console.log 'PARSING MIN MAX'
      return {
        max_value: data.aggregations.max_agg.value
        min_value: data.aggregations.min_agg.value
      }
