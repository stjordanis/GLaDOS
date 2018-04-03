glados.useNameSpace 'glados',
  ReportCardApp: class ReportCardApp

    @init = ->

      glados.apps.Main.MainGladosApp.hideMainSplashScreen()

      GlobalVariables.CHEMBL_ID = glados.Utils.URLS.getCurrentModelChemblID()
      @scrollSpyHandler = new glados.models.ScrollSpy.ScrollSpyHandler
      ScrollSpyHelper.initializeScrollSpyPinner()
      new glados.views.ScrollSpy.ScrollSpyView
        el: $('.BCK-ScrollSpy')
        model: @scrollSpyHandler
      glados.Utils.checkReportCardByChemblId(GlobalVariables.CHEMBL_ID)

    @hideSection = (sectionID) ->
      @scrollSpyHandler.hideSection(sectionID)
      $('#' + sectionID).hide()
      $('#' + sectionID).addClass('hidden-section')


    @showSection = (sectionID) ->
      @scrollSpyHandler.showSection(sectionID)
      $('#' + sectionID).show()
      $('#' + sectionID).addClass('section')
      $('#' + sectionID).addClass('scrollspy')

    @registerSection = (sectionID, sectionLabel) ->
      @scrollSpyHandler.registerSection(sectionID, sectionLabel)
      sectionModel = new Backbone.Model
        title: sectionLabel
        expanded: true

      new glados.views.ReportCards.SectionView
        el: $('#' + sectionID)
        model:sectionModel

    # you can provide chembld iD or a model already created
    @initMiniReportCard = (Entity, $containerElem, chemblID, model, customTemplate, additionalTemplateParams={},
    fetchModel=true, customColumns)->

      if not model
        model = new Entity({id: chemblID})

      view = new glados.views.MiniReportCardView
        el: $containerElem
        model: model
        entity: Entity
        custom_template: customTemplate
        additional_params: additionalTemplateParams
        custom_columns: customColumns

      if not fetchModel
        view.render()
      else
        model.fetch()

    # ------------------------------------------------------------------------------------------------------------------
    # Embedding
    # ------------------------------------------------------------------------------------------------------------------
    @EMBED_MINI_REPORT_CARD_URL_GENERATOR =
    Handlebars.compile("#{glados.Settings.GLADOS_BASE_URL_FULL}embed/#mini_report_card/{{entity_type}}/{{id}}")