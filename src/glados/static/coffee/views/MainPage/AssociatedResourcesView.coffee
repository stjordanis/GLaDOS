glados.useNameSpace 'glados.views.MainPage',
  AssociatedResourcesView: Backbone.View.extend

    initialize: ->
      console.log 'im the associated resources view !!!!'
      @render()

    render: ->
      console.log 'I will render chembl associated resources :)'
#      $defaultImageToShow = $(@el).find('#base-img')
#      @showItem($defaultImageToShow)

    events:
      'mouseover #ntd-link': "showItem"
      'mouseover #sure-link': "showItem"
      'mouseover #uni-link': "showItem"

    showItem: (event) ->
      console.log 'Element: ', event








