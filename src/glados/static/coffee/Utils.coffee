glados.useNameSpace 'glados',
  Utils:
    getFormattedNumber: (numberToFormat)->
      if numberToFormat < -Math.pow(10, 20)
        return numberToFormat.toExponential()
      if numberToFormat < Math.pow(10, 6)
        return numeral(numberToFormat).format('0,[.]00')
      return numeral(numberToFormat).format('0.[0000]e+0')

    # this is to support using dots for nested properties in the list settings
    #for example, if you have the following object
    # a = {
    #    b: {
    #      c: 2
    #       }
    #     }
    # you can use the function like this getNestedValue(a, 'b.c'.split('.'))
    getNestedValue: (nestedObj, nestedComparatorsStr, forceAsNumber=false, customNullValueLabel) ->

      nullValueLabel = customNullValueLabel
      nullValueLabel ?= glados.Settings.DEFAULT_NULL_VALUE_LABEL
      nullReturnVal = if forceAsNumber then -Number.MAX_VALUE else nullValueLabel

      nestedComparatorsList = nestedComparatorsStr.split('.')
      if nestedComparatorsList.length == 1
        value = nestedObj[(nestedComparatorsList.shift())]
        if not value?
          return nullReturnVal
        if forceAsNumber
          return parseFloat(value)
        else
          return value
      else
        prop = nestedComparatorsList.shift()
        newObj = nestedObj[(prop)]
        if !newObj?
          return nullReturnVal

        return @getNestedValue(newObj, nestedComparatorsList.join('.'))


    # given an model and a list of columns to show, it gives an object ready to be passed to a
    # handlebars template, with the corresponding values for each column
    # handlebars only allow very simple logic, we have to help the template here and
    # give it everything as ready as possible
    getColumnsWithValues: (columns, model) ->

      return columns.map (colDescription) ->

        returnCol = {}
        returnCol.name_to_show = colDescription['name_to_show']

        col_value = glados.Utils.getNestedValue(model.attributes, colDescription.comparator, forceAsNumber=false,
        customNullValueLabel=colDescription.custom_null_vale_label)

        returnCol['format_class'] = colDescription.format_class

        if colDescription.num_decimals? and colDescription.format_as_number\
        and col_value != glados.Settings.DEFAULT_NULL_VALUE_LABEL

          col_value = col_value.toFixed(colDescription.num_decimals)

        if _.isBoolean(col_value)
          returnCol['value'] = if col_value then 'Yes' else 'No'
        else
          returnCol['value'] = col_value

        if _.has(colDescription, 'parse_function')
          returnCol['value'] = colDescription['parse_function'](col_value)

        returnCol['has_link'] = _.has(colDescription, 'link_base')
        returnCol['is_secondary_link'] = colDescription.secondary_link == true
        returnCol['is_function_link'] = colDescription.function_link == true
        returnCol['execute_on_render'] = colDescription.execute_on_render == true

        if returnCol['is_function_link']
          returnCol['function_parameters'] = (glados.Utils.getNestedValue(model.attributes, paramComp) \
          for paramComp in colDescription.function_parameters).join(',')
          returnCol['function_constant_parameters'] = colDescription.function_constant_parameters
          returnCol['function_key'] = colDescription.function_key

        returnCol['link_url'] = model.get(colDescription['link_base']) unless !returnCol['has_link']
        if _.has(colDescription, 'image_base_url')
          img_url = model.get(colDescription['image_base_url'])
          returnCol['img_url'] = img_url
        if _.has(colDescription, 'custom_field_template')
          returnCol['custom_html'] = Handlebars.compile(colDescription['custom_field_template'])
            val: returnCol['value']

        # This method should return a value based on the parameter, not modify the parameter
        return returnCol


    #gets the image url from the first column with values that has a 'img_url'
    getImgURL: (columnsWithValues) ->

      for col in columnsWithValues
        if col['img_url']?
          return col['img_url']
      return null

    cachedTemplateFunctions: {}
    # the element must define a data-hb-template, which is the id of the handlebars template to be used
    fillContentForElement: ($element, paramsObj={}, customTemplate)->

      if customTemplate?
        templateSelector = '#' + customTemplate
      else
        templateSelector = '#' + $element.attr('data-hb-template')

      if not glados.Utils.cachedTemplateFunctions[templateSelector]?
        templateFunction = Handlebars.compile($(templateSelector).html())
        glados.Utils.cachedTemplateFunctions[templateSelector] = templateFunction
      else
        templateFunction = glados.Utils.cachedTemplateFunctions[templateSelector]

      $element.html templateFunction(paramsObj)

    getContentFromTemplate: (templateID, paramsObj={}, customTemplateContent) ->

      templateSelector = '#' + templateID

      if not glados.Utils.cachedTemplateFunctions[templateSelector]? or customTemplateContent?
        if customTemplateContent?
          templateContent = customTemplateContent
        else
          templateContent = $(templateSelector).html()
        templateFunction = Handlebars.compile(templateContent)
        glados.Utils.cachedTemplateFunctions[templateSelector] = templateFunction
      else
        templateFunction = glados.Utils.cachedTemplateFunctions[templateSelector]

      return templateFunction(paramsObj)


    # Helper function to prevent links from navigating to an url that is inside the same js page
    # If key_up is true will override for enter listening on links
    # If key_up is false will override for click listening on links
    # callback should be a function that receives the href of the link and knows how to handle it
    getNavigateOnlyOnNewTabLinkEventHandler: (key_up, callback)->
      handler = (event)->
        # Disables link navigation by click or enter, unless it redirects to a non results page
        if $(this).attr("target") != "_blank" and \
          (not key_up or event.keyCode == 13) and \
          not(event.ctrlKey or GlobalVariables.IS_COMMAND_KEY_DOWN)
            event.preventDefault()
            callback($(this).attr("href"))
      return handler

    overrideHrefNavigationUnlessTargetBlank: ($jquery_element, callback)->
      $jquery_element.click(
        glados.Utils.getNavigateOnlyOnNewTabLinkEventHandler(false, callback)
      )
      $jquery_element.keyup(
        glados.Utils.getNavigateOnlyOnNewTabLinkEventHandler(true, callback)
      )

    # for server side collections, it assumes that all the results are already on the client
    pluckFromListItems: (list, propertyName) ->

      if list.allResults?
        return (glados.Utils.getNestedValue(model, propertyName) for model in list.allResults)
      else
        return (glados.Utils.getNestedValue(model.attributes, propertyName) for model in list.models)

    renderLegendForProperty: (property, collection, $legendContainer, enableSelection=true) ->

      if not property.legendModel?
        property.legendModel = new glados.models.visualisation.LegendModel
          property: property
          collection: collection
          enable_selection: enableSelection

      if not property.legendView?
        property.legendView = new LegendView
          model: property.legendModel
          el: $legendContainer
      else
        property.legendView.render()

      $legendContainer.find('line, path').css('fill', 'none')

    getDegreesFromRadians: (radians) -> radians * 180 / Math.PI
    getRadiansFromDegrees: (degrees) -> (degrees * Math.PI) / 180

    Buckets:
      mergeBuckets: (buckets, maxCategories, model, aggName) ->

        if buckets.length > maxCategories
          start = maxCategories - 1
          stop = buckets.length - 1
          bucketsToMerge = buckets[start..stop]

          if model?
            mergedLink = model.getMergedLink(bucketsToMerge, aggName)
          else
            mergedLink = ''

          othersBucket =
            doc_count: _.reduce(_.pluck(bucketsToMerge, 'doc_count'), ((a, b) -> a + b))
            key: glados.Visualisation.Activity.OTHERS_LABEL
            link: mergedLink

          buckets = buckets[0..start-1]
          buckets.push(othersBucket)

        return buckets

      getElasticRanges: (minValue, maxValue, numCols) ->

        interval = parseFloat((Math.ceil(Math.abs(maxValue - minValue)) / numCols).toFixed(2))
        if interval == 0
          interval = 0.01

        ranges = []
        from = minValue
        to = minValue + interval
        for col in [0..numCols-1]
          from = parseFloat(from.toFixed(2))
          to = parseFloat(to.toFixed(2))
          ranges.push
            from: from
            to: to

          from += interval
          to += interval

        return ranges

      getIntervalSize: (maxValue, minValue, numColumns) ->
        parseFloat((Math.ceil(Math.abs(maxValue - minValue)) / numColumns).toFixed(2))

      getBucketsList: (elasticBucketsObj) ->

        buckets = []
        for key, bucket of elasticBucketsObj
          bucket.key = key
          buckets.push bucket

        return buckets
    ErrorMessages:

      getJQXHRErrorText: (jqXHR) ->
        if jqXHR.status == 0
          return console.log jqXHR.getAllResponseHeaders()
        else
          jqXHR.status + ': ' + jqXHR.statusText

      showLoadingErrorMessageGen: ($progressElem) ->
        return (jqXHR, textStatus, errorThrown) ->
          errorDetails = glados.Utils.ErrorMessages.getJQXHRErrorText(jqXHR)
          $progressElem.html 'Error loading data (' + errorDetails + ')'

      getErrorCardContent: (jqXHR) ->
        errorDetails = glados.Utils.ErrorMessages.getJQXHRErrorText(jqXHR)
        return Handlebars.compile($('#Handlebars-Common-ErrorInCard').html())
          msg: errorDetails

      getCollectionErrorContent: (jqXHR, customExplanation) ->
        errorDetails = glados.Utils.ErrorMessages.getJQXHRErrorText(jqXHR)
        return Handlebars.compile($('#Handlebars-Common-CollectionErrorMsg').html())
          msg: errorDetails
          custom_explanation: customExplanation

      getErrorImageContent: (jqXHR) ->
        errorDetails = glados.Utils.ErrorMessages.getJQXHRErrorText(jqXHR)
        return Handlebars.compile($('#Handlebars-Common-ErrorInImage').html())
          msg: errorDetails

    Text:
      getTextForEllipsis: (originalText, originalWidth, containerLimit ) ->

        numChars = originalText.length
        charLength = originalWidth / numChars
        # reduce by num numchars because font characters are not all of the same width
        numChars = Math.ceil(containerLimit / charLength) - 2
        textLimit = numChars - 4
        textLimit = if textLimit < 0 then 0 else textLimit
        return originalText[0..textLimit] + '...'

    QueryStrings:
      getQueryStringForItemsList: (chemblIDs, idAttribute) ->
        return idAttribute + ':(' + ('"' + id + '"' for id in chemblIDs).join(' OR ') + ')'

    Tooltips:
      # removes all qtips from and element, the elements that have a tooltip must have the property
      # data-qtip-configured set to 'yes'
      destroyAllTooltips: ($elem) ->

        $elemsWithToolTip = $($elem).find('[data-qtip-configured=yes],[data-qtip-configured=true]')
        $elemsWithToolTip.each (index, elem) ->
          $(elem).qtip('destroy', true)
          $(elem).attr('data-qtip-configured', null )

      getQltipSafePostion: ($jqueryElement, $tooltipContent=null) ->
        screenWidth = $( window ).width()
        screenHeight = $( window ).height()
        offset = $jqueryElement.offset()
        elemCenterX = offset.left - $( window ).scrollLeft() + $jqueryElement.width()/2
        elemCenterY = offset.top - $( window ).scrollTop() + $jqueryElement.height()/2

        horizontalPos = null
        if elemCenterX < screenWidth/4
          horizontalPos = 'left'
        else if elemCenterX >= screenWidth/4 and elemCenterX <= 3*screenWidth/4
          horizontalPos = 'center'
        else
          horizontalPos = 'right'

        myVert = null
        atVert = null
        if elemCenterY <= screenHeight/2
          myVert = 'top'
          atVert = 'bottom'
        else
          myVert = 'bottom'
          atVert = 'top'
        console.log 'ELEM data', offset.top, $tooltipContent.height()
        if $tooltipContent and $tooltipContent.height() >= offset.top
          myVert = 'top'
          atVert = 'bottom'
        return {
          my: myVert+' '+horizontalPos
          at: atVert+' '+horizontalPos
        }

      destroyAllTooltipsWhenMouseIsOut: ($container, mouseX, mouseY)->

        scrollTop = $(window).scrollTop()
        scrollLeft = $(window).scrollLeft()
        itemsContainerOffset = $container.offset().top

        containerYUpperLimit =  itemsContainerOffset - scrollTop
        containerYLowerLimit = (itemsContainerOffset + $container.height()) - scrollTop
        containerLeftLimit = $container.offset().left - scrollLeft
        containerRightLimit = ($container.offset().left + $container.width()) - scrollLeft

        xIsOut = (mouseX < containerLeftLimit) or (mouseX > containerRightLimit)
        yIsOut = (mouseY < containerYUpperLimit) or (mouseY > containerYLowerLimit)

        if xIsOut or yIsOut
          glados.Utils.Tooltips.destroyAllTooltips($($container))

