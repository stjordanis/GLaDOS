# This takes care of the handling of the report card of a compound

loadCompound = ->
  compound = new Compound
  compound.url = 'https://www.ebi.ac.uk/chembl/api/data/molecule/CHEMBL25.json'
  compound.fetch({async:false})
  return compound


### *
  * Initializes de CNCView
  * @param {Compound} model, base model for the view
  * @param {JQuery} element that renders the model.
  * @return {CompoundNameClassificationView} the view that has been created
###
initCNCView = (model, top_level_elem) ->

  cncView = new CompoundNameClassificationView
    model: compound
    el: top_level_elem

  return cncView

