glados.useNameSpace 'glados.models.paginatedCollections.esSchema',
  # --------------------------------------------------------------------------------------------------------------------
  # Elastic Search Faceting Handler
  # --------------------------------------------------------------------------------------------------------------------
  FacetingHandler: class FacetingHandler

    # ------------------------------------------------------------------------------------------------------------------
    # Class Context
    # ------------------------------------------------------------------------------------------------------------------

    @CATEGORY_FACETING: 'CATEGORY'
    @INTERVAL_FACETING: 'INTERVAL'

    @NUM_INTERVALS: 10

    @EMPTY_CATEGORY: '- N/A -'
    @OTHERS_CATEGORY: 'Other Categories'
    @KEY_REGEX_REPLACE: /[^A-Z0-9_-]/gi

    @getAllFacetGroupsSelectedQuery: (faceting_handlers_list)->
      all_facets_query = []
      for faceting_handler_i in faceting_handlers_list
        fh_query_i = faceting_handler_i.getSelectedFacetsFilterQuery()
        if fh_query_i
          all_facets_query.push(fh_query_i)
      if all_facets_query.length == 0
        return null
      return all_facets_query

    @generateFacetsForIndex: (es_index)->
      facets = {}
      if not _.has(glados.models.paginatedCollections.esSchema.GLaDOS_es_GeneratedSchema, es_index)
        throw new 'ERROR: '+es_index+' was not found in the Generated Schema for GLaDOS!'
      gs_data = glados.models.paginatedCollections.esSchema.GLaDOS_es_GeneratedSchema[es_index]
      cur_pos = 1
      for prop_i in _.keys(gs_data)
        if gs_data[prop_i].aggregatable
          facets[prop_i] = {
            label: django.gettext(gs_data[prop_i].label_id)
            label_mini: django.gettext(gs_data[prop_i].label_mini_id)
            show: false
            position: cur_pos++
            faceting_handler: glados.models.paginatedCollections.esSchema.FacetingHandler.getNewFacetingHandler(
              es_index, prop_i
            )
          }
      return facets

    @getNewFacetingHandler: (es_index, es_property)->
      es_index_schema =  glados.models.paginatedCollections.esSchema.GLaDOS_es_GeneratedSchema[es_index]
      if not es_index_schema
        throw "ERROR! unknown elastic index "+es_index
      property_type = es_index_schema[es_property]
      if not property_type
        throw "ERROR! unknown "+es_property+" for elastic index "+es_index
      if not property_type.aggregatable
        throw "ERROR! "+es_property+" for elastic index "+es_index+" is not aggregatable"
      if property_type.type == String or property_type.type == Boolean
        return new FacetingHandler(
          es_index,
          es_property,
          property_type.type,
          FacetingHandler.CATEGORY_FACETING,
          property_type
        )
      else if property_type.type == Number
        return new FacetingHandler(
          es_index,
          es_property,
          property_type.type,
          FacetingHandler.INTERVAL_FACETING,
          property_type
        )
      else
        throw "ERROR! "+es_property+" for elastic index "+es_index+" with type "+property_type.type\
            +" does not have a defined faceting type"

    # ------------------------------------------------------------------------------------------------------------------
    # Instance Context
    # ------------------------------------------------------------------------------------------------------------------

    constructor: (@es_index, @es_property_name, @js_type, @faceting_type, @property_type)->
      @faceting_keys_inorder = null
      @faceting_data = null
      @min_value = null
      @max_value = null
      @intervals_size = null

    # ------------------------------------------------------------------------------------------------------------------
    # Query and Parse Facets to/from Elasticsearch
    # ------------------------------------------------------------------------------------------------------------------

    # Interval aggregations require 2 calls to find out first the min/max range
    # and then create an histogram of n columns
    addQueryAggs: (es_query_aggs, first_call)->
      if @faceting_type == FacetingHandler.CATEGORY_FACETING
        if first_call
          es_query_aggs[@es_property_name] = {
            terms:
              field: @es_property_name
          }
          # Elastic search has a bug for terms aggregation in booleans with missing values
          if @js_type != Boolean
            es_query_aggs[@es_property_name].terms.missing = FacetingHandler.EMPTY_CATEGORY

      else if @faceting_type == FacetingHandler.INTERVAL_FACETING
        if first_call
          es_query_aggs[@es_property_name+'_MIN'] = {
            min:
              field: @es_property_name
          }
          es_query_aggs[@es_property_name+'_MAX'] = {
            max:
              field: @es_property_name
          }
        else
          if not _.isNumber(@min_value) or not _.isNumber(@max_value)
            throw "ERROR! The minimum and maximum have not been requested yet!"
          else
            es_query_aggs[@es_property_name] = {
              histogram:
                field: @es_property_name
                interval: @intervals_size
            }

    # will round the interval size to the closest 10*, 20* or 50*
    roundInterval: ()->
      # Do the division first to prevent number overflow
      @intervals_size = (@max_value/FacetingHandler.NUM_INTERVALS)-(@min_value/FacetingHandler.NUM_INTERVALS)
      isSmallFloat = @intervals_size < 5 and not @property_type.integer
      if isSmallFloat
        @intervals_size *= Math.pow(10, 20)
      curLevel = -1
      curNum = @intervals_size
      loop
        curLevel += 1
        lastNum = curNum
        curNum = Math.ceil(curNum/10)
        if curNum == 1 or curNum == 0
          break
      if lastNum > 5
        curLevel++
        lastNum = 1
      else if lastNum > 2
        lastNum = 5
      else if lastNum > 1
        lastNum = 2
      else
        lastNum = 1
      @intervals_size = lastNum * Math.pow(10, curLevel)
      if isSmallFloat
        @intervals_size /= Math.pow(10, 20)

    parseESResults: (es_aggregations_data, first_call)->

      if first_call
        @faceting_keys_inorder = []
        @faceting_data = {}
      if @faceting_type == FacetingHandler.CATEGORY_FACETING
        aggregated_data = es_aggregations_data[@es_property_name]
        if aggregated_data
          if not _.isUndefined(aggregated_data.buckets)
            for bucket_i in aggregated_data.buckets
              fKey = bucket_i.key
              @parseCategoricalKey(fKey)
              @faceting_data[fKey] = {
                index: @faceting_keys_inorder.length
                count: bucket_i.doc_count
                selected: false
                key_for_humans: @parseCategoricalKey(fKey)
              }
              @faceting_keys_inorder.push(bucket_i.key)

          if not _.isUndefined(aggregated_data.sum_other_doc_count) and aggregated_data.sum_other_doc_count > 0
              @faceting_data[FacetingHandler.OTHERS_CATEGORY] = {
                index: @faceting_keys_inorder.length
                count: aggregated_data.sum_other_doc_count
                selected: false
                key_for_humans: FacetingHandler.OTHERS_CATEGORY
              }
              @faceting_keys_inorder.push(FacetingHandler.OTHERS_CATEGORY)
      else if @faceting_type == FacetingHandler.INTERVAL_FACETING
        if first_call
          @min_value = es_aggregations_data[@es_property_name+'_MIN'].value
          if not _.isNumber(@min_value) and not _.isNaN(@min_value)
            @min_value = Number.MIN_SAFE_INTEGER
          @max_value = es_aggregations_data[@es_property_name+'_MAX'].value
          if not _.isNumber(@max_value) and not _.isNaN(@max_value)
            @max_value = Number.MAX_SAFE_INTEGER
          @roundInterval()
        else
          if not _.isNumber(@min_value) or not _.isNumber(@max_value)
            throw "ERROR! The minimum and maximum have not been requested yet!"
          aggregated_data = es_aggregations_data[@es_property_name]
          if aggregated_data
            if not _.isUndefined(aggregated_data.buckets)
              for bucket_i in aggregated_data.buckets
                fKey = @parseIntervalKey(bucket_i.key, @intervals_size)
                @faceting_data[fKey] = {
                  min: bucket_i.key
                  max: bucket_i.key + @intervals_size
                  index: @faceting_keys_inorder.length
                  count: bucket_i.doc_count
                  selected: false
                  key_for_humans: fKey
                }
                @faceting_keys_inorder.push(fKey)

    parseCategoricalKey: (key) ->

      esIndex = @es_index
      propName = @es_property_name

      return glados.models.visualisation.PropertiesFactory.parseValueForEntity(esIndex, propName, key)

    parseIntervalKey: (key, intervalsSize) ->
      formatKey = glados.Utils.getFormattedNumber
      if intervalsSize == 1
        return formatKey(key)
      else
        return formatKey(key) + "  to  " + formatKey(key + intervalsSize)

    needsSecondRequest:()->
      return @faceting_type == FacetingHandler.INTERVAL_FACETING

    # ------------------------------------------------------------------------------------------------------------------
    # Facets Functions
    # ------------------------------------------------------------------------------------------------------------------

    clearFacets: ()->
      @faceting_keys_inorder = []
      @faceting_data = {}

    hasSelection: ()->
      if @faceting_data
        for facet_key, facet_data of @faceting_data
          if facet_data.selected
            return true
      return false

    getSelectedFacetsFilterQuery: ()->
      selected_query = {
        bool:{ should:[] }
      }
      for facet_key, facet_data of @faceting_data
        if facet_data.selected
          selected_query.bool.should.push(@getFilterQueryForFacetKey(facet_key))
      if selected_query.bool.should.length ==0
        return null
      return selected_query

    toggleKeySelection: (facet_key)->
      @faceting_data[facet_key].selected = not @faceting_data[facet_key].selected
      return @faceting_data[facet_key].selected

    clearSelections: ->
      for fKey, fData of @faceting_data
        fData.selected = false

    getFacetingHandlerId: ()->
      return (@es_index+"_"+@es_property_name).replace(FacetingHandler.KEY_REGEX_REPLACE,"__")

    getFacetId:(facet_key)->
      return (@es_property_name+"_facet_"+@faceting_data[facet_key].index)\
        .replace(FacetingHandler.KEY_REGEX_REPLACE,"__")

    getFilterQueryForFacetKey: (facet_key)->
      filter_terms_query = null
      if @faceting_type == FacetingHandler.CATEGORY_FACETING
        if facet_key == FacetingHandler.OTHERS_CATEGORY
          # For the others query we need to negate the non other category facet keys
          filter_terms_query = {
            bool:{ must_not:[] }
          }
          for facet_key_i in @faceting_keys_inorder
            if facet_key_i != FacetingHandler.OTHERS_CATEGORY
              filter_terms_query.bool.must_not.push(@getFilterQueryForFacetKey(facet_key_i))
        else if facet_key == FacetingHandler.EMPTY_CATEGORY
          filter_terms_query = {
              bool:
                must_not:
                  exists:
                    field: @es_property_name
            }
        else
          filter_terms_query = {term: {}}
          filter_terms_query.term[@es_property_name] = facet_key
      else if @faceting_type == FacetingHandler.INTERVAL_FACETING
        filter_terms_query = {range: {}}
        filter_terms_query.range[@es_property_name] = {
          'gte': @faceting_data[facet_key].min
          'lt': @faceting_data[facet_key].max
        }

      return filter_terms_query
