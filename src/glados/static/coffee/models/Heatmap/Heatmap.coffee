glados.useNameSpace 'glados.models.Heatmap',
  Heatmap: Backbone.Model.extend

    # See
    # https://drive.google.com/drive/folders/18PYFsg1D_EG911woYF45IsMfO1PIAzfg?usp=sharing
    defaults:
      filter_property: 'molecule_chembl_id'
      aggregations: ['molecule_chembl_id', 'target_chembl_id']

    initialize: ->

      @config = arguments[0].config
      testMode = @config.test_mode
      @set('state', glados.models.Heatmap.STATES.INITIAL_STATE)
      minWindowLoadSizeFactor = @config.custom_min_window_load_size_factor
      minWindowLoadSizeFactor ?= glados.models.Heatmap.LOAD_WINDOW.MIN_LOAD_SIZE_WINDOW_FACTOR
      wFactor = @config.custom_w_factor
      wFactor ?= glados.models.Heatmap.LOAD_WINDOW.W_FACTOR
      @set('min_window_load_size_factor', minWindowLoadSizeFactor)
      @set('w_factor', wFactor)

      return
      @generateDependentLists() unless testMode

    # ------------------------------------------------------------------------------------------------------------------
    # Generate base structures
    # ------------------------------------------------------------------------------------------------------------------
    generateDependentLists: ->

      if @config.generator_axis == glados.models.Heatmap.AXES_NAMES.Y_AXIS
        @y_axis_list = @config.generator_list
      else if @config.generator_axis == glados.models.Heatmap.AXES_NAMES.X_AXIS
        @x_axis_list = @config.generator_list

      if @config.generate_from_downloaded_items

        generatorFunction = @config.opposite_axis_generator_function
        collection = @config.generator_list
        deferreds = collection.getAllResults()

        thisHeatmap = @
        $.when.apply($, deferreds).done ->

          itemsIds = collection.getItemsIDs(onlySelected=false)

          if thisHeatmap.config.generator_axis == glados.models.Heatmap.AXES_NAMES.Y_AXIS
            thisHeatmap.x_axis_list = generatorFunction(itemsIds)
            thisHeatmap.switchToState(glados.models.Heatmap.STATES.DEPENDENT_LISTS_CREATED)
          else if thisHeatmap.config.generator_axis == glados.models.Heatmap.AXES_NAMES.X_AXIS
            thisHeatmap.y_axis_list = generatorFunction(itemsIds)
            thisHeatmap.switchToState(glados.models.Heatmap.STATES.DEPENDENT_LISTS_CREATED)

    checkListLength: (list) ->

      thisHeatmap = @

      if list.getItemsFetchingState() \
      != glados.models.paginatedCollections.PaginatedCollectionBase.ITEMS_FETCHING_STATES.ITEMS_READY

        list.fetch()
        list.once( glados.models.paginatedCollections.PaginatedCollectionBase.EVENTS.ITEMS_FETCHING_STATE_CHANGED,
          ( -> thisHeatmap.checkListLength(list)))
      else

        # if both lists are ready, I can switch to the next state
        xAxisListItemsReady = @x_axis_list.getItemsFetchingState() \
          == glados.models.paginatedCollections.PaginatedCollectionBase.ITEMS_FETCHING_STATES.ITEMS_READY
        yAxisListItemsReady = @y_axis_list.getItemsFetchingState() \
          == glados.models.paginatedCollections.PaginatedCollectionBase.ITEMS_FETCHING_STATES.ITEMS_READY

        if xAxisListItemsReady and yAxisListItemsReady
          @switchToState(glados.models.Heatmap.STATES.HEATMAP_TOTAL_SIZE_KNOWN)

    fetchTotalNumberOfRowsAndColumns: ->

      @checkListLength(@y_axis_list)
      @checkListLength(@x_axis_list)

    # ------------------------------------------------------------------------------------------------------------------
    # state changing
    # ------------------------------------------------------------------------------------------------------------------
    switchToState: (newState) ->

      currentState = @get('state')
      if currentState != newState
        @set('state', newState)

        if newState == glados.models.Heatmap.STATES.DEPENDENT_LISTS_CREATED
          @fetchTotalNumberOfRowsAndColumns()
        else if newState == glados.models.Heatmap.STATES.HEATMAP_TOTAL_SIZE_KNOWN
          @createMatrixInitialStructure()
          @setInitialWindow()
          @switchToState(glados.models.Heatmap.STATES.READY_TO_RENDER)

    generateBaseRowsORColsList: (totalNumItems, isCol=false) ->

      baseID = if isCol then 'COL_TO_LOAD' else 'ROW_TO_LOAD'

      baseRowList = []
      for i in [0..totalNumItems-1]
        baseObj =
          id: "#{baseID}:#{i}"
          load_state: glados.models.Heatmap.ITEM_LOAD_STATES.TO_LOAD
          currentPosition: i
        baseRowList.push(baseObj)

      return baseRowList

    createMatrixInitialStructure: ->

      console.log 'CREATE MATRIX STRUCTURE'
      totalNumRows = @y_axis_list.getTotalRecords()
      baseRowList = @generateBaseRowsORColsList(totalNumRows, isCol=false)
      totalNumCols = @x_axis_list.getTotalRecords()
      baseColsList = @generateBaseRowsORColsList(totalNumCols, isCol=true)

      console.log('baseRowList: ', baseRowList)
      console.log('baseColsList: ', baseColsList)
      #base data structure
      cleanMatrixStructure =
        columns: baseColsList
        rows: baseRowList
        links: []
        rows_index: []
        rows_curr_position_index: {}
        columns_index: {}
        columns_curr_position_index: {}
        cell_max_pchembl_value_avg: 0
        cell_min_pchembl_value_avg: 0
        cell_max_activity_count: 0
        cell_min_activity_count: 0

      console.log 'matrix: ', cleanMatrixStructure
      @set('matrix', cleanMatrixStructure)

    # ------------------------------------------------------------------------------------------------------------------
    # Window
    # ------------------------------------------------------------------------------------------------------------------
    setInitialWindow: ->

      loadWindowStruct =
        x_axis:
          to_load_frontiers: []
          loading_frontiers: []
          loaded_frontiers: []
          error_frontiers: []
        y_axis:
          to_load_frontiers: []
          loading_frontiers: []
          loaded_frontiers: []
          error_frontiers: []

      @set('load_window_struct', loadWindowStruct)

    resetLoadWindow: -> @setInitialWindow()

    informVisualWindowLimits: (axis, initialItemNumber, lastItemNumber) ->

      console.log 'BBB ---'
      console.log 'BBB informVisualWindowLimits: ', axis, initialItemNumber, lastItemNumber

      if axis == glados.models.Heatmap.AXES_NAMES.X_AXIS
        axisLength = @x_axis_list.getTotalRecords()
      else if axis == glados.models.Heatmap.AXES_NAMES.Y_AXIS
        axisLength = @y_axis_list.getTotalRecords()

      axisPropName = glados.models.Heatmap.AXES_PROPERTY_NAMES[axis]
      loadWindowStruct = @get('load_window_struct')

      visualWindowLength = lastItemNumber - initialItemNumber + 1
      loadWindowLengthMustBe = visualWindowLength * @get('w_factor')

      frontierCandidateStart = initialItemNumber - Math.ceil((loadWindowLengthMustBe - visualWindowLength)/2)
      frontierCandidateStart = 1 if frontierCandidateStart < 1
      frontierCandidateStart = axisLength if frontierCandidateStart > axisLength

      frontierCandidateEnd = lastItemNumber + Math.floor((loadWindowLengthMustBe - visualWindowLength)/2)
      frontierCandidateEnd = 1 if frontierCandidateEnd < 1
      frontierCandidateEnd = axisLength if frontierCandidateEnd > axisLength

      loadingFrontierCandidate =
        start: frontierCandidateStart
        end: frontierCandidateEnd

      # Now that I have  candidate I chop it, I will create a structure full of trues for the candidate
      loadingFrontierCandidateBools = {}
      for i in [loadingFrontierCandidate.start..loadingFrontierCandidate.end]
        loadingFrontierCandidateBools[i] = true
      console.log 'AAA loadingFrontierCandidateBools: ', loadingFrontierCandidateBools

      console.log 'AAA loadingFrontierCandidate: ', loadingFrontierCandidate
      @chopLoadCandidate(axisPropName, loadingFrontierCandidateBools, visualWindowLength)
      @updateAbsoluteFrontierLimits()
      toLoadFrontiers = loadWindowStruct[axisPropName].to_load_frontiers
      # if there is only 1 to load frontier there can be no gaps
      if toLoadFrontiers.length > 1
        @removeToLoadGaps() unless @config.test_mode
      @processLoadWindowStruct() unless @config.test_mode

    chopLoadCandidate: (axisPropName, loadingFrontierCandidateBools, visualWindowLength, ignoreMinToLoadLimit=false) ->

      if axisPropName == glados.models.Heatmap.AXES_PROPERTY_NAMES.X_AXIS
        axisLength = @x_axis_list.getTotalRecords()
      else if axisPropName == glados.models.Heatmap.AXES_PROPERTY_NAMES.Y_AXIS
        axisLength = @y_axis_list.getTotalRecords()

      loadWindowStruct = @get('load_window_struct')

      loadingFrontiers = loadWindowStruct[axisPropName].loading_frontiers
      loadedFrontiers = loadWindowStruct[axisPropName].loaded_frontiers
      toLoadFrontiers = loadWindowStruct[axisPropName].to_load_frontiers
      allFrontiers = _.union(loadingFrontiers, loadedFrontiers)

      # Now I kill the the items based on the loading and loaded frontiers
      for frontier in allFrontiers
        for i in [frontier.start..frontier.end]
          item = loadingFrontierCandidateBools[i]
          if item?
            loadingFrontierCandidateBools[i] = false

      # now I create the loaded frontiers from the surviving item
      candidateKeys = (parseInt(i) for i in _.keys(loadingFrontierCandidateBools)).sort( (a, b) -> a - b )
      toLoadFrontiers = loadWindowStruct[axisPropName].to_load_frontiers

      minFrontierSize = @get('min_window_load_size_factor') * visualWindowLength

      i = 0
      creatingFrontier = false
      newFrontier = {}
      numCandidateKeys = candidateKeys.length
      while i < numCandidateKeys
        currentItemNumber = candidateKeys[i]
        nexItemNumber = candidateKeys[i + 1]
        currentItemIsAlive = loadingFrontierCandidateBools[currentItemNumber] == true
        nexItemIsAlive = loadingFrontierCandidateBools[nexItemNumber] == true

        iAmAtTheEnd = i == numCandidateKeys - 1
        if not creatingFrontier and currentItemIsAlive
          newFrontier.start = currentItemNumber
          creatingFrontier = true

        if (creatingFrontier and not nexItemIsAlive) or iAmAtTheEnd
          newFrontier.end = currentItemNumber
          newFrontierSize = newFrontier.end - newFrontier.start + 1
          touchesAxisEnd = (newFrontier.end >= axisLength)

          if (newFrontierSize > minFrontierSize) or ignoreMinToLoadLimit or touchesAxisEnd
            console.log 'new frontier: start; ', newFrontier.start, 'end; ', newFrontier.end
            toLoadFrontiers.push newFrontier
          newFrontier = {}
          creatingFrontier = false

        i += 1

    updateAbsoluteFrontierLimits: ->

      loadWindowStruct = @get('load_window_struct')

      for axisPropName in _.values(glados.models.Heatmap.AXES_PROPERTY_NAMES)

        toLoadFrontiers = loadWindowStruct[axisPropName].to_load_frontiers
        loadingFrontiers = loadWindowStruct[axisPropName].loading_frontiers
        loadedFrontiers = loadWindowStruct[axisPropName].loaded_frontiers

        allFrontiers = _.union(toLoadFrontiers, loadingFrontiers, loadedFrontiers)
        if allFrontiers.length == 0
          continue

        minStart = loadWindowStruct[axisPropName].min_start
        minStart ?= Number.MAX_SAFE_INTEGER
        maxEnd = loadWindowStruct[axisPropName].max_end
        maxEnd ?= Number.MIN_SAFE_INTEGER

        for frontier in allFrontiers
          currentStart = frontier.start
          currentEnd = frontier.end

          if currentStart < minStart
            minStart = currentStart

          if currentEnd > maxEnd
            maxEnd = currentEnd

        loadWindowStruct[axisPropName].min_start = minStart
        loadWindowStruct[axisPropName].max_end = maxEnd


    # if the gaps are too big we can not include them, but for now this should work.
    removeToLoadGaps: ->

      @updateAbsoluteFrontierLimits()
      loadWindowStruct = @get('load_window_struct')

      for axisPropName in _.values(glados.models.Heatmap.AXES_PROPERTY_NAMES)

        minStart = loadWindowStruct[axisPropName].min_start
        maxEnd = loadWindowStruct[axisPropName].max_end

        # Now I create a load candidate from minStart to minEnd
        loadingFrontierCandidateBools = {}
        for i in [minStart..maxEnd]
          loadingFrontierCandidateBools[i] = true

        # visual window length doesn't matter here
        @chopLoadCandidate(axisPropName, loadingFrontierCandidateBools, visualWindowLength=-1,
          ignoreMinToLoadLimit=false)

    processLoadWindowStruct: ->

      console.log 'processLoadWindowStruct: '
      loadWindowStruct = @get('load_window_struct')

      for axis in _.values(glados.models.Heatmap.AXES_PROPERTY_NAMES)
        toLoadFrontiers = loadWindowStruct[axis].to_load_frontiers

        console.log 'toLoadFrontiers: ', toLoadFrontiers

        currentFrontier = toLoadFrontiers.shift()
        while currentFrontier?
          console.log 'currentFrontier: ', currentFrontier
          @loadAxisFrontier(axis, currentFrontier.start, currentFrontier.end)
          currentFrontier = toLoadFrontiers.shift()


    loadAxisFrontier: (axisProp, start, end) ->

      loadWindowStruct = @get('load_window_struct')
      loadingFrontiers = loadWindowStruct[axisProp].loading_frontiers
      loadingWindow =
        start: start
        end: end

      loadingFrontiers.push(loadingWindow)

      console.log 'CCC ---'
      console.log 'CCC loadAxisFrontier: ', axisProp, start, end
      matrix = @get('matrix')
      if axisProp == glados.models.Heatmap.AXES_PROPERTY_NAMES.X_AXIS
        items = matrix.columns
        list = @x_axis_list
      else if axisProp == glados.models.Heatmap.AXES_PROPERTY_NAMES.Y_AXIS
        items = matrix.rows
        list = @y_axis_list

      for item in items[(start-1)..(end-1)]
        item.load_state = glados.models.Heatmap.ITEM_LOAD_STATES.LOADING

      @trigger(glados.models.Heatmap.EVENTS.VISUAL_WINDOW.ITEMS_STATE_UPDATED)

      thisModel = @
      console.log 'CCC list: ', list
      list.once 'reset', ->
        console.log 'CCC DATA WAS RECEIVED! ', axisProp, start, end
        thisModel.receiveItems(axisProp, start, end, list.models)
        list.disableFetchingForMatrixMode()

      list.enableFetchingForMatrixMode()
      # this really needs to be done in a better way by defining better events for the collections.
      list.fetchByItemNumber(start, end)

    receiveItems: (axisProp, start, end, models) ->

      console.log 'CCC RECEIVING ITEMS ', axisProp, start, end, models
      matrix = @get('matrix')
      if axisProp == glados.models.Heatmap.AXES_PROPERTY_NAMES.X_AXIS
        itemsToUpdate = matrix.columns
        indexToUpdate = matrix.columns_index
      else if axisProp == glados.models.Heatmap.AXES_PROPERTY_NAMES.Y_AXIS
        itemsToUpdate = matrix.rows
        indexToUpdate = matrix.rows_index

      console.log 'CCC matrix: ', matrix
      for i in [start-1..end-1]
        positionInModels = i - start + 1
        itemToUpdate = itemsToUpdate[i]
        newAttributes = models[positionInModels].attributes
        $.extend(itemToUpdate, newAttributes)
        itemToUpdate.load_state = glados.models.Heatmap.ITEM_LOAD_STATES.LOADED

        indexToUpdate[itemToUpdate.id] = itemToUpdate

      console.log 'CCC TRIGGERING ITEMS_STATE_UPDATED EVENT ', axisProp
      @trigger(glados.models.Heatmap.EVENTS.VISUAL_WINDOW.ITEMS_STATE_UPDATED)


    # ------------------------------------------------------------------------------------------------------------------
    # Headers/footers link
    # ------------------------------------------------------------------------------------------------------------------
    getColHeaderLink: (colID) ->

      console.log 'CCC get header url'
      colsIndex = @get('matrix').columns_index
      if colsIndex[colID].header_url?
        return colsIndex[colID].header_url

      linkGeneratorFunc = @config.col_header_Link_generator
      url = linkGeneratorFunc(colsIndex[colID])
      colsIndex[colID].header_url = url

      return url

    getRowHeaderLink: (rowID) ->

      rowsIndex = @get('matrix').rows_index
      if rowsIndex[rowID].header_url?
        return rowsIndex[rowID].header_url

      linkGeneratorFunc = @config.row_header_Link_generator
      url = linkGeneratorFunc(rowsIndex[rowID])
      rowsIndex[rowID].header_url = url

      return url

    # ------------------------------------------------------------------------------------------------------------------
    # helpers for Tooltips
    # ------------------------------------------------------------------------------------------------------------------
    getAxisEntity: (axisName) ->

      if axisName == glados.models.Heatmap.AXES_NAMES.X_AXIS
        return @x_axis_list.getMeta('model')
      else if axisName == glados.models.Heatmap.AXES_NAMES.Y_AXIS
        return @y_axis_list.getMeta('model')

    # ------------------------------------------------------------------------------------------------------------------
    # OLD CODE
    # ------------------------------------------------------------------------------------------------------------------
    fetch: (options) ->

      cleanMatrixConfig =
        columns: []
        rows: []
        links: []
        rows_index: []
        rows_curr_position_index: {}
        columns_index: {}
        columns_curr_position_index: {}
        cell_max_pchembl_value_avg: 0
        cell_min_pchembl_value_avg: 0
        cell_max_activity_count: 0
        cell_min_activity_count: 0
      @set('matrix', cleanMatrixConfig, {silent:true})
      @set('state', glados.models.Aggregations.Aggregation.States.LOADING_BUCKETS)

      @url = glados.models.paginatedCollections.Settings.ES_BASE_URL + '/chembl_activity/_search'
      # Creates the Elastic Search Query parameters and serializes them
      esJSONRequest = JSON.stringify(@getRequestData())
      fetchESOptions =
        url: @url
        data: esJSONRequest
        type: 'POST'
        reset: true

      thisModel = @
      $.ajax(fetchESOptions).done((data) ->
        thisModel.set(thisModel.parse data)
        thisModel.set('state', glados.models.Aggregations.Aggregation.States.INITIAL_STATE)
        aggregations = thisModel.get('aggregations')

        if aggregations[1] == 'target_chembl_id'
          allTargets = thisModel.get('matrix').columns
        else
          allTargets = thisModel.get('matrix').rows

        for target in allTargets
          chemblID = target.target_chembl_id
          thisModel.loadTargetsPrefName(chemblID)
      )

    getLinkToAllActivities: ->
      filter = @get('filter_property') + ':(' + ('"' + id + '"' for id in @get('chembl_ids')).join(' OR ') + ')'
      return Activity.getActivitiesListURL(filter)

    getLinkToFullScreen: ->
      filter = @get('filter_property') + ':(' + ('"' + id + '"' for id in @get('chembl_ids')).join(' OR ') + ')'

      filterProperty = @get('filter_property')
      startingFrom = switch filterProperty
        when 'molecule_chembl_id' then 'Compounds'
        else 'Targets'

      return Activity.getActivitiesListURL(filter) + '/state/matrix_fs_' + startingFrom
    #-------------------------------------------------------------------------------------------------------------------
    # Parsing
    #-------------------------------------------------------------------------------------------------------------------
    parse: (data) ->

      rowsToPosition = {}
      colsToPosition = {}
      links = {}

      rowsList = []
      latestRowPos = 0
      colsList = []
      latestColPos = 0

      rowsIndex = {}
      columnsIndex = {}
      # this is to optimize the cell colouring
      MaxPchemblValueAvg = -Number.MAX_VALUE
      MinPchemblValueAvg = Number.MAX_VALUE
      MaxActivityCount = -Number.MAX_VALUE
      MinActivityCount = Number.MAX_VALUE

      aggregations = @get('aggregations')
      rowsAggName = aggregations[0] + glados.models.Activity.ActivityAggregationMatrix.AGG_SUFIX
      colsAggName = aggregations[1] + glados.models.Activity.ActivityAggregationMatrix.AGG_SUFIX

      rowsBuckets = data.aggregations[rowsAggName].buckets

      for rowBucket in rowsBuckets

        # what do I know now? I am seeing a new compound
        rowID = rowBucket.key

        # remember that  the orgiginalIndex and currentPosition are used to sort easily the nodes.
        rowObj = @createNewRowObj(rowID, rowBucket, latestRowPos)

        rowsList.push rowObj
        rowsToPosition[rowID] = latestRowPos
        latestRowPos++

        # now check the targets for this molecule
        colBuckets = rowBucket[colsAggName].buckets
        for colBucket in colBuckets

          # what do I know now? there is a target, it could be new or repeated
          colID = colBucket.key
          colPos = colsToPosition[colID]

          # it is new!
          if not colPos?

            colObj = @createNewColObj(colID, colBucket, latestColPos)

            colsList.push colObj
            colsToPosition[colID] = latestColPos
            columnsIndex[colID] = colObj
            latestColPos++
          # it is not new, I just need to update the row properties
          else
            colObj = colsList[colPos]


          # now I know that there is a new intersection!
          cellObj = @createNewCellObj(rowID, colID, colBucket)
          if cellObj.pchembl_value_avg? and cellObj.pchembl_value_avg > MaxPchemblValueAvg
            MaxPchemblValueAvg = cellObj.pchembl_value_avg
          if cellObj.pchembl_value_avg? and cellObj.pchembl_value_avg < MinPchemblValueAvg
            MinPchemblValueAvg = cellObj.pchembl_value_avg

          if cellObj.activity_count? and cellObj.activity_count > MaxActivityCount
            MaxActivityCount = cellObj.activity_count
          if cellObj.activity_count? and cellObj.activity_count < MinActivityCount
            MinActivityCount = cellObj.activity_count

          #update row and col properties
          @updateColOrRowObj(rowObj, colBucket)
          @updateColOrRowObj(colObj, colBucket)

          # here the compound and target must exist in the lists, recalculate the positions
          compPos = rowsToPosition[rowID]
          colPos = colsToPosition[colID]

          # create object for storing links if not yet there
          if not links[compPos]?
            links[compPos] = {}

          links[compPos][colPos] = cellObj

      @addRowsWithNoData(rowsList, latestRowPos)

      result =
        columns: colsList
        rows: rowsList
        links: links
        rows_index: _.indexBy(rowsList, 'id')
        rows_curr_position_index: _.indexBy(rowsList, 'currentPosition')
        columns_index: columnsIndex
        columns_curr_position_index: _.indexBy(colsList, 'currentPosition')
        cell_max_pchembl_value_avg: MaxPchemblValueAvg
        cell_min_pchembl_value_avg: MinPchemblValueAvg
        cell_max_activity_count: MaxActivityCount
        cell_min_activity_count: MinActivityCount

      console.log 'result', result

      return {"matrix": result}

    getRelatedRowIDsFromColID: (colID, links=@get('matrix').links, colsIndex=@get('matrix').columns_index ) ->

      originalColIndex = colsIndex[colID].originalIndex

      relatedRows = []
      for rowKey, rowObj of links
        if rowObj[originalColIndex]?
          relatedRows.push rowObj[originalColIndex].row_id

      return relatedRows

    # the user requested some items for rows. For some
    addRowsWithNoData: (rowsList, latestRowPos) ->

      rowsIDsGot = (row.id for row in rowsList)
      missingRowsIDs = _.difference(@get('chembl_ids'), rowsIDsGot)
      aggregations = @get('aggregations')
      for id in missingRowsIDs

        mockBucket =
          key: id
        newRow = @createNewRowObj(id, mockBucket, latestRowPos)
        rowsList.push(newRow)
        latestRowPos++

    getRowFooterLink: (rowID) ->

      rowsIndex = @get('matrix').rows_index
      if rowsIndex[rowID].footer_url?
        return rowsIndex[rowID].footer_url

      aggregations = @get('aggregations')
      if aggregations[0] == 'target_chembl_id'
        activityFilterBase = 'target_chembl_id:'
      else
        activityFilterBase = 'molecule_chembl_id:'

      activityFilter = activityFilterBase + rowID
      url = Activity.getActivitiesListURL(activityFilter)
      rowsIndex[rowID].footer_url = url
      return url

#    getColHeaderLink: (colID) ->
#
#      colsIndex = @get('matrix').columns_index
#      if colsIndex[colID].header_url?
#        return colsIndex[colID].header_url
#
#      aggregations = @get('aggregations')
#      if aggregations[1] == 'target_chembl_id'
#        urlGenerator = $.proxy(Target.get_report_card_url, Target)
#      else
#        urlGenerator = $.proxy(Compound.get_report_card_url, Compound)
#
#      url = urlGenerator(colID)
#      colsIndex[colID].header_url = url
#      return url


    getColFooterLink: (colID) ->

      colsIndex = @get('matrix').columns_index
      if colsIndex[colID].footer_url?
        return colsIndex[colID].footer_url

      aggregations = @get('aggregations')
      if aggregations[0] == 'target_chembl_id'
        rowsPropName = 'target_chembl_id'
        colsPropName = 'molecule_chembl_id'
      else
        colsPropName = 'target_chembl_id'
        rowsPropName = 'molecule_chembl_id'

      relatedRows = @getRelatedRowIDsFromColID(colID)
      rowsListFilter = rowsPropName + ':(' + ('"' + row + '"' for row in relatedRows).join(' OR ') + ')'
      colActivityFilter = colsPropName + ':' + colID + ' AND ' + rowsListFilter
      url = Activity.getActivitiesListURL(colActivityFilter)
      colsIndex[colID].footer_url = url
      return url

    getLinkToAllColumns: ->

      matrix = @get('matrix')

      if matrix.link_to_all_columns?
        return matrix.link_to_all_columns

      allRows = matrix.rows
      aggregations = @get('aggregations')
      allRowsIDS = _.pluck(allRows, 'id')

      if aggregations[1] == 'target_chembl_id'
        filter = "_metadata.related_compounds.chembl_ids.\\*:(#{allRowsIDS.join(' OR ')})"
        link = Target.getTargetsListURL(filter)
      else
        filter = "_metadata.related_targets.chembl_ids.\\*:(#{allRowsIDS.join(' OR ')})"
        link = Compound.getCompoundsListURL(filter)

      matrix.link_to_all_columns = link
      return link

    createNewRowObj: (rowID, rowBucket, latestRowPos) ->

      aggregations = @get('aggregations')
      if aggregations[0] == 'molecule_chembl_id'
        @createNewCompObj(rowID, rowBucket, latestRowPos)
      else
        @createNewTargObj(rowID, rowBucket, latestRowPos)

    createNewColObj: (colID, colBucket, latestColPos) ->

      aggregations = @get('aggregations')
      if aggregations[1] == 'target_chembl_id'
        @createNewTargObj(colID, colBucket, latestColPos)
      else
        @createNewCompObj(colID, colBucket, latestColPos)

    createNewCompObj: (id, bucket, latestPos) ->
      return {
        id: id
        molecule_pref_name: 'MOL_NAME ' + latestPos
        molecule_chembl_id: bucket.key
        originalIndex: latestPos
        currentPosition: latestPos
        activity_count: 0
        pchembl_value_max: null
        hit_count: 0
      }

    createNewTargObj: (id, bucket, latestPos) ->

      return {
        id: id
        pref_name: glados.models.Activity.ActivityAggregationMatrix.LOADING_DATA_LABEL
        target_chembl_id: bucket.key
        originalIndex: latestPos
        currentPosition: latestPos
        activity_count: 0
        pchembl_value_max: null
        hit_count: 0
      }


    createNewCellObj: (rowID, colID, colBucket) ->
      id: rowID + '-' + colID
      row_id: rowID
      col_id: colID
      activity_count: colBucket.doc_count
      pchembl_value_avg: colBucket.pchembl_value_avg.value
      pchembl_value_max: colBucket.pchembl_value_max.value

    updateColOrRowObj: (obj, colBucket) ->

      obj.activity_count += colBucket.doc_count
      obj.hit_count++

      newPchemblMax = colBucket.pchembl_value_max.value
      currentPchemblMax = obj.pchembl_value_max

      if not currentPchemblMax?
        obj.pchembl_value_max = newPchemblMax
      else if newPchemblMax?
        obj.pchembl_value_max = Math.max(newPchemblMax, currentPchemblMax)


    #-------------------------------------------------------------------------------------------------------------------
    # Additional data
    #-------------------------------------------------------------------------------------------------------------------
    loadTargetsPrefName: (targetChemblID) ->

      targetUrl = glados.Settings.WS_BASE_URL + 'target/' + targetChemblID + '.json'

      aggregations = @get('aggregations')
      if aggregations[1] == 'target_chembl_id'
        targetsIndex = @get('matrix').columns_index
      else
        targetsIndex = @get('matrix').rows_index

      thisModel = @
      $.getJSON(targetUrl).done( (data) ->
        targetPrefName = data.pref_name
        targetToUpdate = targetsIndex[targetChemblID]
        targetToUpdate.pref_name = targetPrefName
      ).fail( ->
        targetToUpdate = targetsIndex[targetChemblID]
        targetToUpdate.pref_name = thisModel.ERROR_LOADING_DATA_LABEL
      ).always(-> thisModel.trigger(glados.models.Activity.ActivityAggregationMatrix.TARGET_PREF_NAMES_UPDATED_EVT, targetChemblID))

    getValuesListForProperty: (propName) ->

      values = []

      for rowIndex, row of @get('matrix').links
        for colIndex, cell of row
          value = cell[propName]
          values.push(value) unless not value?

      return values

    sortMatrixRowsBy: (propName, reverse=false) ->

      matrix = @get('matrix')
      newOrders = _.sortBy(matrix.rows, propName)
      newOrders = newOrders.reverse() if reverse
      #avoid issues with inconsistency of the objects pointed
      matrix.rows = []
      for row, index in newOrders
        matrix.rows_index[row.id].currentPosition = index
        matrix.rows.push(matrix.rows_index[row.id])

      matrix.rows_curr_position_index = _.indexBy(matrix.rows, 'currentPosition')

    sortMatrixColsBy: (propName, reverse=false) ->

      matrix = @get('matrix')
      newOrders = _.sortBy(matrix.columns, propName)
      newOrders = newOrders.reverse() if reverse
      matrix.columns = []
      for col, index in newOrders
        matrix.columns_index[col.id].currentPosition = index
        matrix.columns.push(matrix.columns_index[col.id])

      matrix.columns_curr_position_index = _.indexBy(matrix.columns, 'currentPosition')
    #returns a list with all the links
    getDataList: ->

      dataList = []
      for rowID, row of @get('matrix').links
        for colID, cell of row
          dataList.push cell

      return dataList

    #-------------------------------------------------------------------------------------------------------------------
    # Request data
    #-------------------------------------------------------------------------------------------------------------------
    addQueryToRequest: (requestData, idsList) ->

      queryString = @get('query_string')
      if queryString
        requestData.query =
          query_string:
            query: queryString
        return

      requestData.query =
        terms: {}

      requestData.query.terms[@get('filter_property')] = idsList

    addAggregationsToRequest: (requestData) ->

      aggsList = @get('aggregations')
      requestData.aggs = {}
      aggsContainer = requestData.aggs
      # only the first aggregation will support up to 10000 elements, the rest is limited to reduce the amount of data
      # that will be received.
      aggSize = 10000
      for propName in aggsList
        aggName = propName + glados.models.Activity.ActivityAggregationMatrix.AGG_SUFIX

        aggsContainer[aggName] =
          terms:
            field: propName,
            size: aggSize,
            order:
              _count: "desc"
          aggs: {}

        aggsContainer = aggsContainer[aggName].aggs
        aggSize = 1000000

    addCellAggregationsToRequest: (requestData) ->

      aggsList = @get('aggregations')
      aggsContainer = requestData.aggs

      for i in [0..aggsList.length-1]
        propName = aggsList[i]
        aggName = propName + glados.models.Activity.ActivityAggregationMatrix.AGG_SUFIX
        if i != aggsList.length - 1
          aggsContainer = aggsContainer[aggName].aggs
        else
          aggsContainer[aggName].aggs =
            pchembl_value_avg:
              avg:
                field: "pchembl_value"
            pchembl_value_max:
              max:
                field: "pchembl_value"

    getRequestData: ->

      idsList = @get('chembl_ids')

      requestData =
        size: 0

      @addQueryToRequest(requestData, idsList)
      @addAggregationsToRequest(requestData)
      @addCellAggregationsToRequest(requestData)

      console.log 'requestData: ', requestData
      return requestData

glados.models.Activity.ActivityAggregationMatrix.LOADING_DATA_LABEL = 'Loading...'
glados.models.Activity.ActivityAggregationMatrix.ERROR_LOADING_DATA_LABEL = '(Error Loading data)'
glados.models.Activity.ActivityAggregationMatrix.TARGET_PREF_NAMES_UPDATED_EVT = 'TARGET_PREF_NAMES_UPDATED_EVT'
glados.models.Activity.ActivityAggregationMatrix.AGG_SUFIX = '_agg'
glados.models.Heatmap.STATES =
  INITIAL_STATE: 'INITIAL_STATE'
  DEPENDENT_LISTS_CREATED: 'DEPENDENT_LISTS_CREATED'
  HEATMAP_TOTAL_SIZE_KNOWN: 'HEATMAP_TOTAL_SIZE_KNOWN'
  READY_TO_RENDER: 'READY_TO_RENDER'
glados.models.Heatmap.ITEM_LOAD_STATES =
  TO_LOAD: 'TO_LOAD' # The item needs to be loaded
  LOADING: 'LOADING' # The item is being fetched
  LOADED: 'LOADED' # The item is loaded, the data was received
  ERROR: 'ERROR' # There was an error while fetching the data for the item.
glados.models.Heatmap.AXES_NAMES =
  Y_AXIS: 'Y_AXIS'
  X_AXIS: 'X_AXIS'
glados.models.Heatmap.AXES_PROPERTY_NAMES =
  Y_AXIS: 'y_axis'
  X_AXIS: 'x_axis'
glados.models.Heatmap.LOAD_WINDOW =
  W_FACTOR: 3 # how big is the load window in comparison to the visual window. For example, if visual window is 2x2,
  # with w_factor equal to 2, the load window will be 4x4.
  MIN_LOAD_SIZE_WINDOW_FACTOR: 1 # as the visual window moves, the load candidates are not always of the full size, this
  # tells which is the smallest size of chunks to load. for example, if the visual window is 2X2, and this factor is 1
  # if will only trigger the load of at least 2 items per axis.
  # This is important because without any limit, the heatmap could start to load the items one by one as the user
  # moves the visualisation
glados.models.Heatmap.EVENTS =
  VISUAL_WINDOW:
    COLS_HEADERS_UPDATED: 'COLS_HEADERS_UPDATED'
    COLS_FOOTERS_UPDATED: 'COLS_FOOTERS_UPDATED'
    ROWS_HEADERS_UPDATED: 'ROWS_HEADERS_UPDATED'
    ROWS_FOOTERS_UPDATED: 'ROWS_FOOTERS_UPDATED'
    ITEMS_STATE_UPDATED: 'ITEMS_STATE_UPDATED'
glados.models.Heatmap.MAX_RELATED_IDS_LISTS = 79
