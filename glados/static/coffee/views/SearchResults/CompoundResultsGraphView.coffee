# this view is in charge of showing the results of a compound search as a graph
CompoundResultsGraphView = Backbone.View.extend(ResponsiviseViewExt).extend

  initialize: ->

    @$vis_elem = $('#BCK-CompResultsGraphContainer')
    updateViewProxy = @setUpResponsiveRender()

  render: ->

    @paintGraph()
    $(@el).find('select').material_select()

  paintGraph: ->

    console.log 'painting graph'

    # --------------------------------------
    # Data
    # --------------------------------------
    molecules = [
      {
        molecule_chembl_id: "CHEMBL8659",
        molecule_type: "Small molecule",
        therapeutic_flag: false,
        molecule_properties: {acd_logd: "4.83", acd_logp: "7.42", acd_most_apka: "4.78", acd_most_bpka: null,}
        max_phase: 2,
        mol_wt: 16.5,
      },
      {
        molecule_chembl_id: "CHEMBL9960",
        molecule_type: "Small molecule",
        therapeutic_flag: true,
        molecule_properties: {acd_logd: "5.33", acd_logp: "5.33", acd_most_apka: "12.82", acd_most_bpka: "3.63"}
        max_phase: 3,
        mol_wt: 40.5,
      },
      {
        molecule_chembl_id: "CHEMBL3545375",
        molecule_type: "Antibody",
        therapeutic_flag: false,
        molecule_properties: null
        max_phase: 4,
        mol_wt: 140.5,
      },
      {
        molecule_chembl_id: "CHEMBL6962",
        molecule_type: "Small molecule",
        therapeutic_flag: false,
        molecule_properties: {acd_logd: "0.73", acd_logp: "2.64", acd_most_apka: null, acd_most_bpka: "10.01"},
        max_phase: 1
        mol_wt: 32.0,
      }
      {
        molecule_chembl_id: "CHEMBL1863514"
        molecule_type: "Enzyme",
        therapeutic_flag: true,
        molecule_properties: null,
        max_phase: 2,
        mol_wt: 20.0,
      }
      {
        molecule_chembl_id: "CHEMBL6995",
        molecule_type: "Small molecule",
        therapeutic_flag: false,
        molecule_properties: {acd_logd: "-1.51", acd_logp: "0.59", acd_most_apka: "13.88", acd_most_bpka: "9.43"}
        max_phase: 3,
        mol_wt: 25.0,

      }

    ]

    # --------------------------------------
    # pre-configuration
    # --------------------------------------
    margin =
      top: 20
      right: 20
      bottom: 20
      left: 20

    padding =
      right:20
      left: 20
      text_left: 60
      bottom: 20
      top: 20

    XAXIS = 'x-axis'
    YAXIS = 'y-axis'
    COLOUR = 'colour'

    labelerProperty = 'molecule_chembl_id'
    currentPropertyX = 'mol_wt'
    currentPropertyY = 'mol_wt'
    currentPropertyColour = 'mol_wt'

    elemWidth = $(@el).width()
    height = width = 0.8 * elemWidth

    svg = d3.select('#' + @$vis_elem.attr('id'))
            .append('svg')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    # --------------------------------------
    # Add background rectangle
    # --------------------------------------
    svg.append("rect")
      .attr("class", "background")
      .style("fill", "white")
      .attr("width", width)
      .attr("height", width)

    # --------------------------------------
    # scales
    # --------------------------------------
    # infers type from the first non null/undefined value,
    # this will be used to generate the correct scale.
    inferPropsType = (dataList) ->

      for datum in dataList
        if datum?
          type =  typeof datum
          return type

    # builds a linear scale to position the circles
    # when the data is numeric, range is 0 to canvas width,
    # taking into account the padding
    buildLinearNumericScale = (dataList, axis) ->

      minVal = Number.MAX_VALUE
      maxVal = Number.MIN_VALUE

      for datum in dataList
        if datum > maxVal
          maxVal = datum
        if datum < minVal
          minVal = datum

      scaleDomain = [minVal, maxVal]

      console.log 'axis: ', axis

      range = switch
        when axis == XAXIS then [padding.left, width - padding.right]
        when axis == YAXIS then [height - padding.bottom, padding.top]
        when axis == COLOUR then ['#ede7f6', '#311b92']

      console.log 'range: ', range

      return d3.scale.linear()
        .domain(scaleDomain)
        .range(range)

    # builds an ordinal scale to position the circles
    # when the data is string, range is 0 to canvas width,
    # taking into account the padding
    buildOrdinalStringScale = (dataList, axis) ->

      if axis == COLOUR
        return d3.scale.category20()
          .domain(dataList)

      range = switch
        when axis == XAXIS then [padding.text_left, width - padding.right]
        when axis == YAXIS then [height - padding.bottom, padding.top]

      return d3.scale.ordinal()
        .domain(dataList)
        .rangePoints(range)


    getScaleForProperty = (molecules, property, axis) ->

      dataList = _.pluck(molecules, property)

      type = inferPropsType(dataList)
      console.log 'type is: ', type
      scale = switch
        when type == 'number' then buildLinearNumericScale(dataList, axis)
        when type == 'string' then buildOrdinalStringScale(dataList, axis)

      return scale

    getXCoordFor = getScaleForProperty(molecules, currentPropertyX, XAXIS)
    getYCoordFor = getScaleForProperty(molecules, currentPropertyY, YAXIS)
    getColourFor = getScaleForProperty(molecules, currentPropertyColour, COLOUR)

    console.log 'color scale range: ', getColourFor.range()
    console.log 'color scale domain: ', getColourFor.domain()

    # --------------------------------------
    # Add axes
    # --------------------------------------
    xAxis = d3.svg.axis().scale(getXCoordFor).orient("bottom")

    svg.append("g")
      .attr("class", "x-axis")
      .attr("transform", "translate(0," + (height - 20) + ")")
      .call(xAxis)
      .append("text")
      .attr("class", "x-axis-label")
      .attr("x", width)
      .attr("y", -6)
      .style("text-anchor", "end")
      .text(currentPropertyX)

    yAxis = d3.svg.axis().scale(getYCoordFor).orient("left")

    svg.append("g")
      .attr("class", "y-axis")
      .attr("transform", "translate(" + (padding.left - 5) + ", 0)")
      .call(yAxis)
      .append("text")
      .attr("class", "y-axis-label")
      .attr("x", 0)
      .text(currentPropertyY)

    # --------------------------------------
    # Draw dots
    # --------------------------------------
    svg.selectAll("dot")
      .data(molecules)
      .enter().append("circle")
      .attr("class", "dot")
      .attr("r", 10)
      .attr("cx", (d) -> getXCoordFor(d[currentPropertyX]))
      .attr("cy", (d) -> getYCoordFor(d[currentPropertyY]))
      .attr("fill", (d) -> getColourFor(d[currentPropertyColour]))
      .attr('stroke', 'black')

    # --------------------------------------
    # Draw texts
    # --------------------------------------
    svg.selectAll("dot-label")
      .data(molecules)
      .enter().append("text")
      .attr("class", "dot-label")
      .attr("transform", (d) ->
        return "translate(" + getXCoordFor(d[currentPropertyX]) + ',' +
        getYCoordFor(d[currentPropertyY]) + ")" )
      .attr("font-size", "10px")
      .text((d) -> d[labelerProperty])

    # --------------------------------------
    # Axis selectors
    # --------------------------------------
    $(@el).find(".select-xaxis").on "change", () ->

      if !@value?
        return

      currentPropertyX = @value
      console.log 'x axis: ', currentPropertyX

      getXCoordFor = getScaleForProperty(molecules, currentPropertyX, XAXIS)
      xAxis = d3.svg.axis().scale(getXCoordFor).orient("bottom")

      t = svg.transition().duration(1000)

      t.selectAll("g.x-axis")
        .call(xAxis)
      t.selectAll('text.x-axis-label')
        .text(currentPropertyX)
      t.selectAll("circle.dot")
        .attr("cx", (d) -> getXCoordFor(d[currentPropertyX]))
      t.selectAll("text.dot-label")
        .attr("transform", (d) ->
          return "translate(" + getXCoordFor(d[currentPropertyX]) + ',' +
          getYCoordFor(d[currentPropertyY]) + ")" )

    $(@el).find(".select-yaxis").on "change", () ->

      if !@value?
        return

      currentPropertyY = @value
      console.log 'y axis: ', currentPropertyY

      getYCoordFor = getScaleForProperty(molecules, currentPropertyY, YAXIS)
      yAxis = d3.svg.axis().scale(getYCoordFor).orient("left")

      t = svg.transition().duration(1000)

      t.selectAll("g.y-axis")
        .call(yAxis)
      t.selectAll('text.y-axis-label')
        .text(currentPropertyY)
      t.selectAll("circle.dot")
        .attr("cy", (d) -> getYCoordFor(d[currentPropertyY]))
      t.selectAll("text.dot-label")
        .attr("transform", (d) ->
          return "translate(" + getXCoordFor(d[currentPropertyX]) + ',' +
          getYCoordFor(d[currentPropertyY]) + ")" )

    $(@el).find(".select-colour").on "change", () ->

      if !@value?
        return

      currentPropertyColour = @value
      console.log 'colour axis: ', currentPropertyColour

      getColourFor = getScaleForProperty(molecules, currentPropertyColour, COLOUR)

      t = svg.transition().duration(1000)

      t.selectAll("circle.dot")
        .attr("fill", (d) -> getColourFor(d[currentPropertyColour]))



