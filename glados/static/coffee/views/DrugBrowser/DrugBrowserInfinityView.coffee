DrugBrowserInfinityView = Backbone.View.extend(PaginatedViewExt).extend

  initialize: ->
    @collection.on 'reset do-repaint sort', @.render, @
    @isInfinite = true
    @containerID = 'DrugInfBrowserCardsContainer'

  render: ->

    console.log('render!')
    @renderSortingSelector()
    @showControls()
    $(@el).find('select').material_select();
    @fill_template(@containerID)
    @fillNumResults()
    @hideInfiniteBrPreolader()

    @setUpLoadingWaypoint()






