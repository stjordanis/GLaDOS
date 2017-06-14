MiniHistogramView = Backbone.View.extend(ResponsiviseViewExt).extend

  initialize: ->
    @maxCategories = arguments[0].max_categories
    console.log 'max categories:', @maxCategories
    @model.on 'change', @render, @
    @$vis_elem = $(@el).find('.BCK-mini-histogram-container')
    updateViewProxy = @setUpResponsiveRender()
    @showPreloader()

  showPreloader: -> glados.Utils.fillContentForElement(@$vis_elem, {}, 'Handlebars-Common-MiniRepCardPreloader')

  # returns the buckets that are going to be used for the visualisation
  # actual buckets may be merged into "other" depending on @maxCategories
  getBucketsForView: ->
    buckets =  @model.get('pie-data')

    if buckets.length > @maxCategories
      start = @maxCategories - 1
      stop = buckets.length - 1
      bucketsToMerge = buckets[start..stop]
      othersBucket =
        doc_count: _.reduce(_.pluck(bucketsToMerge, 'doc_count'), ((a, b) -> a + b))
        key: glados.Visualisation.Activity.OTHERS_LABEL
        link: 'TODO'

      buckets = buckets[0..start-1]
      buckets.push(othersBucket)

    return buckets

  render: ->
    @$vis_elem.empty()
    buckets = @getBucketsForView()

    if buckets.length == 0
      $visualisationMessages = $(@el).find('.BCK-VisualisationMessages')
      $visualisationMessages.html('No data.')
      return

    console.log 'RENDER VIEW!', buckets
    VISUALISATION_WIDTH = $(@el).width()
    VISUALISATION_HEIGHT = 60

    mainContainer = d3.select(@$vis_elem.get(0))
    mainSVGContainer = mainContainer
      .append('svg')
      .attr('class', 'mainSVGContainer')
      .attr('width', VISUALISATION_WIDTH)
      .attr('height', VISUALISATION_HEIGHT)

    thisView = @
    TITLE_Y = 10
    BARS_CONTAINER_HEIGHT = VISUALISATION_HEIGHT - TITLE_Y

    #-------------------------------------------------------------------------------------------------------------------
    # add histogram bars container
    #-------------------------------------------------------------------------------------------------------------------
    barsContainerG = mainSVGContainer.append('g')
      .attr('transform', 'translate(0,' + TITLE_Y + ')')
    barsContainerG.append('rect')
      .attr('height', BARS_CONTAINER_HEIGHT)
      .attr('width', VISUALISATION_WIDTH)
      .classed('bars-background', true)

    #-------------------------------------------------------------------------------------------------------------------
    # add histogram bars groups
    #-------------------------------------------------------------------------------------------------------------------
    bucketNames = (b.key for b in buckets)
    bucketSizes = (b.doc_count for b in buckets)
    console.log 'bucketSizes: ', bucketSizes
    console.log 'max:', _.max(bucketSizes)

    getXForBucket = d3.scale.ordinal()
      .domain(bucketNames)
      .rangeBands([0,VISUALISATION_WIDTH], 0.1)
    getYForBucket = d3.scale.linear()
      .domain([0, _.max(bucketSizes)])
      .range([0, BARS_CONTAINER_HEIGHT])
    barGroups = barsContainerG.selectAll('.bar-group')
      .data(buckets)
      .enter()
      .append('g')
      .classed('bar-group', true)
      .attr('transform', (b) -> 'translate(' + getXForBucket(b.key) + ')')

    barGroups.append('rect')
      .attr('height', BARS_CONTAINER_HEIGHT)
      .attr('width', getXForBucket.rangeBand())
      .classed('background-bar', true)

    barGroups.append('rect')
      .attr('height', (b) -> getYForBucket(b.doc_count))
      .attr('width', getXForBucket.rangeBand())
      .attr('y', (b) -> BARS_CONTAINER_HEIGHT - getYForBucket(b.doc_count) )
      .classed('value-bar', true)

    barGroups.append('rect')
      .attr('height', BARS_CONTAINER_HEIGHT)
      .attr('width', getXForBucket.rangeBand())
      .classed('front-bar', true)


    #-------------------------------------------------------------------------------------------------------------------
    # add title
    #-------------------------------------------------------------------------------------------------------------------
    totalBioactivities = _.reduce(bucketSizes, ((a, b) -> a + b))
    console.log 'totalBioactivities: ', totalBioactivities
    mainSVGContainer.append('text')
      .text('Browse All (' + totalBioactivities + ')')
      .attr('x', VISUALISATION_WIDTH/2)
      .attr('y', TITLE_Y)
      .attr('text-anchor', 'middle')
      .classed('title', true)
      .on('click', ->
        window.open(thisView.model.get('link_to_all'))
      )