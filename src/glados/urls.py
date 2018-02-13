from django.conf.urls import include, url
from django.conf.urls.i18n import i18n_patterns
from django.conf.urls.static import static
from glados.utils import DirectTemplateView
from django.views.decorators.clickjacking import xframe_options_exempt
from django.conf import settings
from . import views
from django.contrib import admin
import glados.grammar.search_parser
from django.views.i18n import JavaScriptCatalog

# ----------------------------------------------------------------------------------------------------------------------
# Translation for Javascript
# ----------------------------------------------------------------------------------------------------------------------
urlpatterns = \
  i18n_patterns(
    url(r'^glados_jsi18n/glados$',
        JavaScriptCatalog.as_view(packages=['glados'], domain='glados'),
        name='js-glados-catalog'),
    url(r'^glados_jsi18n/glados_es_generated$',
        JavaScriptCatalog.as_view(packages=['glados'], domain='glados_es_generated'),
        name='js-glados_es_generated-catalog'),
    url(r'^glados_jsi18n/glados_es_override$',
        JavaScriptCatalog.as_view(packages=['glados'], domain='glados_es_override'),
        name='js-glados_es_override-catalog'),
  )

urlpatterns += [
  # --------------------------------------------------------------------------------------------------------------------
  # Django Admin
  # --------------------------------------------------------------------------------------------------------------------

  url(r'^admin/', include(admin.site.urls)),

  # --------------------------------------------------------------------------------------------------------------------
  # Compounds
  # --------------------------------------------------------------------------------------------------------------------

  url(r'^compound_report_card/(?P<chembl_id>\w+)/$',
      DirectTemplateView.as_view(template_name="glados/compoundReportCard.html"), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/representations/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/RepresentationsToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/sources/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/SourcesToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/withdrawal_info/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/WithdrawnInformationToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/name_and_classification/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/NameAndClassificationToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/mechanism_of_action/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/MechanismOfActionToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/drug_indications/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/IndicationsToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/target_predictions/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/TargetPredictionsToEmbed.html")), ),

   url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/molecule_features/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/MoleculeFeaturesToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/alternate_forms/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/AlternateFormsToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/related_activities/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/BioactivitySummaryToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/related_assays/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/AssaySummaryToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/related_targets/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/TargetSummaryToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/structural_alerts/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CompoundReportCardParts/StructuralAlertsToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/calculated_properties/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/CompoundReportCardParts/CalculatedCompoundParentPropertiesToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/similar/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/CompoundReportCardParts/SimilarCompoundsToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/clinical_data/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/CompoundReportCardParts/ClinicalDataToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/metabolism/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/CompoundReportCardParts/MetabolismToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/helm_notation/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/CompoundReportCardParts/HELMNotationToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/biocomponents/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/CompoundReportCardParts/BiocomponentsToEmbed.html")), ),

  url(r'^compound_metabolism/(?P<chembl_id>\w+)$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/MoleculeMetabolismGraphFS.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/cross_refs/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/CompoundReportCardParts/CrossReferencesToEmbed.html")), ),

  url(r'^compound_report_card/(?P<chembl_id>\w+)/embed/unichem_cross_refs/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/CompoundReportCardParts/UniChemCrossReferencesToEmbed.html")), ),

  url(r'^compounds/(filter/[\S| ]+)?$',
      DirectTemplateView.as_view(template_name="glados/Browsers/browseCompounds.html"), ),
    
  url(r'^drugs/(filter/[\S| ]+)?$',
    DirectTemplateView.as_view(template_name="glados/Browsers/browseDrugs.html"), ),

  # --------------------------------------------------------------------------------------------------------------------
  # Targets
  # --------------------------------------------------------------------------------------------------------------------

  url(r'^target_report_card/(?P<chembl_id>\w+)/$',
      DirectTemplateView.as_view(template_name="glados/targetReportCard.html"), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/name_and_classification/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/TargetReportCardParts/NameAndClassificationToEmbed.html")), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/components/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/TargetReportCardParts/ComponentsToEmbed.html")), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/relations/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/TargetReportCardParts/RelationsToEmbed.html")), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/approved_drugs_clinical_candidates/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/TargetReportCardParts/ApprovedDrugsAndClinicalCandidatesToEmbed.html")), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/bioactivities/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/TargetReportCardParts/AssociatedBioactivitiesToEmbed.html")), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/associated_assays/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/TargetReportCardParts/AssociatedAssaysToEmbed.html")), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/ligand_efficiencies/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/TargetReportCardParts/LigandEfficienciesToEmbed.html")), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/gene_cross_refs/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/TargetReportCardParts/GeneCrossReferencesToEmbed.html")), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/protein_cross_refs/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/TargetReportCardParts/ProteinCrossReferencesToEmbed.html")), ),

  url(r'^target_report_card/(?P<chembl_id>\w+)/embed/associated_compounds/$', xframe_options_exempt(
    DirectTemplateView.as_view(
      template_name="glados/TargetReportCardParts/AssociatedCompoundsToEmbed.html")), ),

  url(r'^targets/(filter/[\S| ]+)?$',
      DirectTemplateView.as_view(template_name="glados/Browsers/browseTargets.html"), ),

  # --------------------------------------------------------------------------------------------------------------------
  # Assays
  # --------------------------------------------------------------------------------------------------------------------

  url(r'^assay_report_card/(?P<chembl_id>\w+)/$',
      DirectTemplateView.as_view(template_name="glados/assayReportCard.html"), ),

  url(r'^assay_report_card/(?P<chembl_id>\w+)/embed/basic_information/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/AssayReportCardParts/BasicInformationToEmbed.html")), ),

  url(r'^assay_report_card/(?P<chembl_id>\w+)/embed/curation_summary/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/AssayReportCardParts/CurationSummaryToEmbed.html")), ),

  url(r'^assay_report_card/(?P<chembl_id>\w+)/embed/bioactivities/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/AssayReportCardParts/AssociatedBioactivitiesToEmbed.html")), ),

  url(r'^assay_report_card/(?P<chembl_id>\w+)/embed/associated_compounds/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/AssayReportCardParts/AssociatedCompoundsToEmbed.html")), ),

  url(r'^assays/(filter/[\S| ]+)?$',
      DirectTemplateView.as_view(template_name="glados/Browsers/browseAssays.html"), ),

  # --------------------------------------------------------------------------------------------------------------------
  # Documents
  # --------------------------------------------------------------------------------------------------------------------

  url(r'^document_report_card/(?P<chembl_id>\w+)/$',
      DirectTemplateView.as_view(template_name="glados/documentReportCard.html"), ),

  url(r'^document_report_card/(?P<chembl_id>\w+)/embed/basic_information/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/DocumentReportCardParts/BasicInformationToEmbed.html")), ),

  url(r'^document_report_card/(?P<chembl_id>\w+)/embed/word_cloud/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/DocumentReportCardParts/WordCloudToEmbed.html")), ),

  url(r'^document_report_card/(?P<chembl_id>\w+)/embed/assay_network/$', xframe_options_exempt(
      DirectTemplateView.as_view(template_name="glados/DocumentReportCardParts/AssayNetworkToEmbed.html")), ),

  url(r'^document_report_card/(?P<chembl_id>\w+)/embed/related_targets/$', xframe_options_exempt(
      DirectTemplateView.as_view(template_name="glados/DocumentReportCardParts/TargetSummaryToEmbed.html")), ),

  url(r'^document_report_card/(?P<chembl_id>\w+)/embed/related_assays/$', xframe_options_exempt(
      DirectTemplateView.as_view(template_name="glados/DocumentReportCardParts/AssaySummaryToEmbed.html")), ),

  url(r'^document_report_card/(?P<chembl_id>\w+)/embed/related_activities/$', xframe_options_exempt(
      DirectTemplateView.as_view(template_name="glados/DocumentReportCardParts/ActivitySummaryToEmbed.html")), ),

  url(r'^document_report_card/(?P<chembl_id>\w+)/embed/related_compounds/$', xframe_options_exempt(
      DirectTemplateView.as_view(template_name="glados/DocumentReportCardParts/CompoundSummaryToEmbed.html")), ),

  url(r'^document_assay_network/(?P<chembl_id>\w+)/$',
      DirectTemplateView.as_view(template_name="glados/DocumentAssayNetwork/DocumentAssayNetwork.html"), ),

  url(r'^documents_with_same_terms/(?P<doc_terms>.+)/$',
    DirectTemplateView.as_view(template_name="glados/DocumentTerms/DocumentTermsSearch.html"), ),

  url(r'^documents/(filter/[\S| ]+)?$',
      DirectTemplateView.as_view(template_name="glados/Browsers/browseDocuments.html"), ),
  # --------------------------------------------------------------------------------------------------------------------
  # Cells
  # --------------------------------------------------------------------------------------------------------------------

  url(r'^cell_line_report_card/(?P<chembl_id>\w+)/$',
      DirectTemplateView.as_view(template_name="glados/cellLineReportCard.html"), ),

  url(r'^cell_line_report_card/(?P<chembl_id>\w+)/embed/basic_information/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CellReportCardParts/BasicInformationToEmbed.html")), ),

  url(r'^cell_line_report_card/(?P<chembl_id>\w+)/embed/related_assays/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CellReportCardParts/AssaySummaryToEmbed.html")), ),

  url(r'^cell_line_report_card/(?P<chembl_id>\w+)/embed/bioactivities/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CellReportCardParts/ActivitySummaryToEmbed.html")), ),

  url(r'^cell_line_report_card/(?P<chembl_id>\w+)/embed/related_compounds/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/CellReportCardParts/CompoundSummaryToEmbed.html")), ),

  url(r'^$', views.main_page, name='main'),

  url(r'^tweets/$', views.get_latest_tweets_json, name='tweets'),

  url(r'^marvin_search_fullscreen/$',
      DirectTemplateView.as_view(template_name="glados/marvin_search_fullscreen.html"), ),

  url(r'^compound_3D_speck/$',
      DirectTemplateView.as_view(template_name="glados/comp_3D_view_speck_fullscreen.html"), ),

  url(r'^cells/(filter/[\S| ]+)?$',
      DirectTemplateView.as_view(template_name="glados/Browsers/browseCells.html"), ),

  # --------------------------------------------------------------------------------------------------------------------
  # Tissues
  # --------------------------------------------------------------------------------------------------------------------
  url(r'^tissue_report_card/(?P<chembl_id>\w+)/$',
      DirectTemplateView.as_view(template_name="glados/tissueReportCard.html"), ),

  url(r'^tissue_report_card/(?P<chembl_id>\w+)/embed/basic_information/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/TissueReportCardParts/BasicInformationToEmbed.html")), ),

  url(r'^tissue_report_card/(?P<chembl_id>\w+)/embed/related_assays/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/TissueReportCardParts/AssaySummaryToEmbed.html")), ),

  url(r'^tissue_report_card/(?P<chembl_id>\w+)/embed/bioactivities/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/TissueReportCardParts/ActivitySummaryToEmbed.html")), ),

  url(r'^tissue_report_card/(?P<chembl_id>\w+)/embed/related_compounds/$', xframe_options_exempt(
    DirectTemplateView.as_view(template_name="glados/TissueReportCardParts/CompoundSummaryToEmbed.html")), ),

  url(r'^tissues/(filter/[\S| ]+)?$',
      DirectTemplateView.as_view(template_name="glados/Browsers/browseTissues.html"), ),
  # --------------------------------------------------------------------------------------------------------------------
  # Tests
  # --------------------------------------------------------------------------------------------------------------------
  url(r'^layout_test/$', DirectTemplateView.as_view(template_name="glados/layoutTest.html"), ),
  url(r'^string_standardisation_test/$', DirectTemplateView.as_view(template_name="glados/stringStandardisationTest.html"), ),
  url(r'^js_tests/$', DirectTemplateView.as_view(template_name="glados/jsTests.html"), ),

  url(r'^acknowledgements/$', views.acks, name='acks'),
  url(r'^faqs/$', views.faqs, name='faqs'),

  url(r'^download_wizard/(?P<step_id>\w+)$', views.wizard_step_json, name='wizard_step_json'),

  # --------------------------------------------------------------------------------------------------------------------
  # Drug Browser
  # --------------------------------------------------------------------------------------------------------------------
  url(r'^drug_browser_infinity/$',
      DirectTemplateView.as_view(template_name="glados/MainPageParts/DrugBrowserParts/browse_drugs_infinity.html"), ),

  # --------------------------------------------------------------------------------------------------------------------
  # Search Results
  # --------------------------------------------------------------------------------------------------------------------

  url(r'^search_results_parser/(?P<search_string>.*?)$',
      glados.grammar.search_parser.parse_url_search, ),

  url(r'^search_results/.*?$',
      DirectTemplateView.as_view(template_name="glados/SearchResultsParts/SearchResultsMain.html"), ),

  url(r'^substructure_search_results/.*?$',
      DirectTemplateView.as_view(template_name="glados/SubstructureSearchResultsParts/SearchResultsMain.html"), ),

  url(r'^similarity_search_results/.*?$',
      DirectTemplateView.as_view(template_name="glados/SimilaritySearchResultsParts/SearchResultsMain.html"), ),

  url(r'^flexmatch_search_results/.*?$',
      DirectTemplateView.as_view(template_name="glados/FlexmatchSearchResultsParts/SearchResultsMain.html"), ),

  # Compound results graph
  url(r'^compound_results_graph/$',
      DirectTemplateView.as_view(template_name="glados/SearchResultsParts/CompoundResultsGraph.html"), ),

  # Compound vs Target Matrix
  url(r'^compound_target_matrix/$',
      DirectTemplateView.as_view(template_name="glados/SearchResultsParts/CompoundTargetMatrix.html"), ),

  # Embedded Compound vs Target Matrix
  url(r'^compound_target_matrix/embed/$',
      DirectTemplateView.as_view(template_name="glados/SearchResultsParts/CompoundTargetMatrixToEmbed.html"), ),

  # --------------------------------------------------------------------------------------------------------------------
  # Activities
  # --------------------------------------------------------------------------------------------------------------------
  url(r'^activities/(filter/[\S| ]+)?$',
      DirectTemplateView.as_view(template_name="glados/Browsers/browseActivities.html"), ),

]

# ----------------------------------------------------------------------------------------------------------------------
# Static Files
# ----------------------------------------------------------------------------------------------------------------------

urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
