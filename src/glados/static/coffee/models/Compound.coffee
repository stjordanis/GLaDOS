Compound = Backbone.Model.extend(DownloadModelOrCollectionExt).extend

  entityName: 'Compound'
  entityNamePlural: 'Compounds'
  idAttribute: 'molecule_chembl_id'
  defaults:
    fetch_from_elastic: true
  initialize: ->

    id = @get('id')
    id ?= @get('molecule_chembl_id')
    @set('id', id)
    @set('molecule_chembl_id', id)

    if @get('fetch_from_elastic')
      @url = glados.models.paginatedCollections.Settings.ES_BASE_URL + '/chembl_molecule/_doc/' + id
    else
      @url = glados.Settings.WS_BASE_URL + 'molecule/' + id + '.json'

    if @get('enable_similarity_map')
      @set('loading_similarity_map', true)
      @loadSimilarityMap()

      @on 'change:molecule_chembl_id', @loadSimilarityMap, @
      @on 'change:reference_smiles', @loadSimilarityMap, @
      @on 'change:reference_smiles_error', @loadSimilarityMap, @

    if @get('enable_substructure_highlighting')
      @set('loading_substructure_highlight', true)
      @loadStructureHighlight()

      @on 'change:molecule_chembl_id', @loadStructureHighlight, @
      @on 'change:reference_ctab', @loadStructureHighlight, @
      @on 'change:reference_smarts', @loadStructureHighlight, @
      @on 'change:reference_smiles_error', @loadStructureHighlight, @

  isParent: ->

    metadata = @get('_metadata')
    if not metadata.hierarchy.parent?
      return true
    else return false

  # --------------------------------------------------------------------------------------------------------------------
  # Sources
  # --------------------------------------------------------------------------------------------------------------------
  hasAdditionalSources: ->

    additionalSourcesState = @get('has_additional_sources')
    if not additionalSourcesState?
      @getAdditionalSources()
    additionalSourcesState = @get('has_additional_sources')
    return additionalSourcesState

  getAdditionalSources: ->

    aditionalSourcesCache = @get('additional_sources')
    if aditionalSourcesCache?
      return aditionalSourcesCache

    metadata = @get('_metadata')
    ownSources = _.unique(v.src_description for v in metadata.compound_records)

    if @isParent()

      childrenSourcesList = (c.sources for c in metadata.hierarchy.children)
      uniqueSourcesObj = {}
      sourcesFromChildren = []
      for sourcesObj in childrenSourcesList
        for source in _.values(sourcesObj)
          srcDescription = source.src_description
          if not uniqueSourcesObj[srcDescription]?
            uniqueSourcesObj[srcDescription] = true
            sourcesFromChildren.push(srcDescription)

      additionalSources = _.difference(sourcesFromChildren, ownSources)
    else
      sourcesFromParent = (v.src_description for v in _.values(metadata.hierarchy.parent.sources))
      additionalSources = _.difference(sourcesFromParent, ownSources)

    if additionalSources.length == 0
      @set({has_additional_sources: false}, {silent:true})
    else
      @set({has_additional_sources: true}, {silent:true})

    additionalSources.sort()

    @set({additional_sources: additionalSources}, {silent:true})
    return additionalSources

  # --------------------------------------------------------------------------------------------------------------------
  # Synonyms and trade names
  # --------------------------------------------------------------------------------------------------------------------
  separateSynonymsAndTradeNames: (rawSynonymsAndTradeNames) ->

    uniqueSynonymsObj = {}
    uniqueSynonymsList = []

    uniqueTradeNamesObj = {}
    uniqueTradeNamesList = []

    for rawItem in rawSynonymsAndTradeNames

      itemName = rawItem.synonyms
      # is this a proper synonym?
      if rawItem.syn_type != 'TRADE_NAME'

        if not uniqueSynonymsObj[itemName]?
          uniqueSynonymsObj[itemName] = true
          uniqueSynonymsList.push(itemName)
      #or is is a tradename?
      else

        if not uniqueTradeNamesObj[itemName]?
          uniqueTradeNamesObj[itemName] = true
          uniqueTradeNamesList.push(itemName)

    return [uniqueSynonymsList, uniqueTradeNamesList]

  calculateSynonymsAndTradeNames: ->

    rawSynonymsAndTradeNames = @get('molecule_synonyms')
    [uniqueSynonymsList, uniqueTradeNamesList] = @separateSynonymsAndTradeNames(rawSynonymsAndTradeNames)

    metadata = @get('_metadata')
    if @isParent()

      rawChildrenSynonymsAndTradeNamesLists = (c.synonyms for c in metadata.hierarchy.children)
      rawChildrenSynonyms = []
      for rawSynAndTNList in rawChildrenSynonymsAndTradeNamesLists
        for syn in rawSynAndTNList
          rawChildrenSynonyms.push(syn)

      [synsFromChildren, tnsFromChildren] = @separateSynonymsAndTradeNames(rawChildrenSynonyms)
      additionalSynsList = _.difference(synsFromChildren, uniqueSynonymsList)
      additionalTnsList = _.difference(tnsFromChildren, uniqueTradeNamesList)

    else

      console.log 'metadata: ', metadata
      rawSynonymsAndTradeNamesFromParent = _.values(metadata.hierarchy.parent.synonyms)
      [synsFromParent, tnsFromParent] = @separateSynonymsAndTradeNames(rawSynonymsAndTradeNamesFromParent)

      additionalSynsList = _.difference(synsFromParent, uniqueSynonymsList)
      additionalTnsList = _.difference(tnsFromParent, uniqueTradeNamesList)

    @set
      only_synonyms: uniqueSynonymsList
      additional_only_synonyms: additionalSynsList
      only_trade_names: uniqueTradeNamesList
      additional_trade_names: additionalTnsList
    ,
      silent: true

  getSynonyms: -> @getWithCache('only_synonyms', @calculateSynonymsAndTradeNames.bind(@))
  getTradenames: -> @getWithCache('only_trade_names', @calculateSynonymsAndTradeNames.bind(@))
  getAdditionalSynonyms: -> @getWithCache('additional_only_synonyms', @calculateSynonymsAndTradeNames.bind(@))
  getAdditionalTradenames: -> @getWithCache('additional_trade_names', @calculateSynonymsAndTradeNames.bind(@))
  getOwnAndAdditionalSynonyms: ->
    synonyms = @getSynonyms()
    additionalSynonyms = @getAdditionalSynonyms()
    return _.union(synonyms, additionalSynonyms)
  getOwnAndAdditionalTradenames: ->
    tradenames = @getTradenames()
    additionalTradenames = @getAdditionalTradenames()
    return _.union(tradenames, additionalTradenames)
  # --------------------------------------------------------------------------------------------------------------------
  # instance cache
  # --------------------------------------------------------------------------------------------------------------------
  getWithCache: (propName, generator) ->

    cache = @get(propName)
    if not cache?
      generator()
    cache = @get(propName)
    return cache

  # --------------------------------------------------------------------------------------------------------------------
  # Family ids
  # --------------------------------------------------------------------------------------------------------------------
  calculateChildrenIDs: ->

    metadata = @get('_metadata')
    childrenIDs = (c.chembl_id for c in metadata.hierarchy.children)
    @set
      children_ids: childrenIDs
    ,
      silent: true

  getChildrenIDs: -> @getWithCache('children_ids', @calculateChildrenIDs.bind(@))
  getParentID: ->
    metadata = @get('_metadata')
    if @isParent()
      return @get('id')
    else
      return metadata.hierarchy.parent.chembl_id

  calculateAdditionalIDs: ->
    metadata = @get('_metadata')
    additionalIDs = []

    if metadata.hierarchy?
      if @.isParent()
        childrenIDs = @getChildrenIDs()
        for childID in childrenIDs
          additionalIDs.push childID
      else
        parentID = @getParentID()
        additionalIDs.push parentID

    @set
      additional_ids: additionalIDs
    ,
      silent: true

  getOwnAndAdditionalIDs: ->
    ownID = @get('id')
    ids = [ownID]
    additionalIDs = @getWithCache('additional_ids', @calculateAdditionalIDs.bind(@))
    for id in additionalIDs
      ids.push id
    return ids

  loadSimilarityMap:  ->

    if @get('reference_smiles_error')
      @set('loading_similarity_map', false)
      @trigger glados.Events.Compound.SIMILARITY_MAP_ERROR
      return

    # to start I need the smiles of the compound and the compared one
    structures = @get('molecule_structures')
    if not structures?
      return

    referenceSmiles = @get('reference_smiles')
    if not referenceSmiles?
      return

    @downloadSimilaritySVG()

  loadStructureHighlight: ->

    if @get('reference_smiles_error')
      @set('loading_substructure_highlight', false)
      @trigger glados.Events.Compound.STRUCTURE_HIGHLIGHT_ERROR
      return

    referenceSmiles = @get('reference_smiles')
    if not referenceSmiles?
      return

    referenceCTAB = @get('reference_ctab')
    if not referenceCTAB?
      return

    referenceSmarts = @get('reference_smarts')
    if not referenceSmarts?
      return

    model = @
    downloadHighlighted = ->
      model.downloadHighlightedSVG()

    @download2DSDF().then ->
      model.downloadAlignedSDF().then downloadHighlighted, downloadHighlighted

  #---------------------------------------------------------------------------------------------------------------------
  # Parsing
  #---------------------------------------------------------------------------------------------------------------------
  parse: (response) ->

    # get data when it comes from elastic
    if response._source?
      objData = response._source
    else
      objData = response

    filterForActivities = 'molecule_chembl_id:' + objData.molecule_chembl_id
    objData.activities_url = Activity.getActivitiesListURL(filterForActivities)

    # Lazy definition for sdf content retrieving
    objData.sdf_url = glados.Settings.WS_BASE_URL + 'molecule/' + objData.molecule_chembl_id + '.sdf'
    objData.sdf_promise = null
    objData.get_sdf_content_promise = ->
      if not objData.sdf_promise
        objData.sdf_promise = $.ajax(objData.sdf_url)
      return objData.sdf_promise

    # Calculate the rule of five from other properties
    if objData.molecule_properties?
      objData.ro5 = objData.molecule_properties.num_ro5_violations == 0
    else
      objData.ro5 = false

    # Computed Image and report card URL's for Compounds
    objData.structure_image = false
    if objData.structure_type == 'NONE' or objData.structure_type == 'SEQ'
      # see the cases here: https://www.ebi.ac.uk/seqdb/confluence/pages/viewpage.action?spaceKey=CHEMBL&title=ChEMBL+Interface
      # in the section Placeholder Compound Images

      if objData.molecule_properties?
        if glados.Utils.Compounds.containsMetals(objData.molecule_properties.full_molformula)
          objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/metalContaining.svg'
      else if objData.molecule_type == 'Oligosaccharide'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/oligosaccharide.svg'
      else if objData.molecule_type == 'Small molecule'

        if objData.natural_product == '1'
          objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/naturalProduct.svg'
        else if objData.polymer_flag == true
          objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/smallMolPolymer.svg'
        else
          objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/smallMolecule.svg'

      else if objData.molecule_type == 'Antibody'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/antibody.svg'
      else if objData.molecule_type == 'Protein'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/peptide.svg'
      else if objData.molecule_type == 'Oligonucleotide'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/oligonucleotide.svg'
      else if objData.molecule_type == 'Enzyme'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/enzyme.svg'
      else if objData.molecule_type == 'Cell'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/cell.svg'
      else #if response.molecule_type == 'Unclassified' or response.molecule_type = 'Unknown' or not response.molecule_type?
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/unknown.svg'


      #response.image_url = glados.Settings.OLD_DEFAULT_IMAGES_BASE_URL + response.molecule_chembl_id
    else
      objData.image_url = glados.Settings.WS_BASE_URL + 'image/' + objData.molecule_chembl_id + '.svg?engine=indigo'
      objData.image_url_png = glados.Settings.WS_BASE_URL + 'image/' + objData.molecule_chembl_id \
          + '.png?engine=indigo'
      objData.structure_image = true

    objData.report_card_url = Compound.get_report_card_url(objData.molecule_chembl_id )

    filterForTargets = '_metadata.related_compounds.all_chembl_ids:' + objData.molecule_chembl_id
    objData.targets_url = Target.getTargetsListURL(filterForTargets)

    @parseChemSpiderXref(objData)
    @parseATCXrefs(objData)
    return objData;

  #---------------------------------------------------------------------------------------------------------------------
  # Get extra xrefs
  #---------------------------------------------------------------------------------------------------------------------
  parseChemSpiderXref: (objData) ->

    molStructures = objData.molecule_structures
    if not molStructures?
      return

    inchiKey = molStructures.standard_inchi_key
    if not inchiKey?
      return

    chemSpiderLink = "https://www.chemspider.com/Search.aspx?q=#{inchiKey}"
    chemSpiderSourceLink = "https://www.chemspider.com/"
    chemSpidetLinkText = "ChemSpider:#{inchiKey}"

    if not objData.cross_references?
      objData.cross_references = []

    objData.cross_references.push
      xref_name: chemSpidetLinkText,
      xref_src: 'ChemSpider',
      xref_id: inchiKey,
      xref_url: chemSpiderLink,
      xref_src_url: chemSpiderSourceLink

  parseATCXrefs: (objData) ->

    metadata = objData._metadata
    if not metadata?
      return

    atcClassifications = metadata.atc_classifications
    if not atcClassifications?
      return

    if atcClassifications.length == 0
      return

    for classification in atcClassifications

      levelsList = []
      for i in [1..5]

        levelNameKey = "level#{i}"
        levelNameData = classification[levelNameKey]

        levelLink = "http://www.whocc.no/atc_ddd_index/?code=#{levelNameData}&showdescription=yes"

        if i != 5
          levelDescKey = "level#{i}_description"
          levelDescData = classification[levelDescKey].split(' - ')[1]
        else
          levelDescData = classification.who_name

        levelsList.push
          name: levelNameData
          description: levelDescData
          link: levelLink

      refsOBJ =
        xref_src: 'ATC'
        xref_src_url: 'https://www.whocc.no/atc_ddd_index/'
        xref_name: 'One ATC Group'
        levels_refs: levelsList

      if not objData.cross_references?
        objData.cross_references = []
    
      objData.cross_references.push refsOBJ

  #---------------------------------------------------------------------------------------------------------------------
  # Similarity
  #---------------------------------------------------------------------------------------------------------------------

  downloadSimilaritySVG: ()->
    @set
      reference_smiles_error: false
      download_similarity_map_error: false
    ,
      silent: true
    model = @
    promiseFunc = (resolve, reject)->
      referenceSmiles = model.get('reference_smiles')
      structures = model.get('molecule_structures')
      if not referenceSmiles?
        reject('Error, there is no reference SMILES PRESENT!')
        return
      if not structures?
        reject('Error, the compound does not have structures data!')
        return
      mySmiles = structures.canonical_smiles
      if not mySmiles?
        reject('Error, the compound does not have SMILES data!')
        return

      if model.get('similarity_map_base64_img')?
        resolve(model.get('similarity_map_base64_img'))
      else
        formData = new FormData()
        formData.append('file', new Blob([referenceSmiles+'\n'+mySmiles], {type: 'chemical/x-daylight-smiles'}), 'sim.smi')
        formData.append('format', 'svg')
        formData.append('height', '500')
        formData.append('width', '500')
        formData.append('sanitize', 0)
        ajax_deferred = $.post
          url: Compound.SMILES_2_SIMILARITY_MAP_URL
          data: formData
          enctype: 'multipart/form-data'
          processData: false
          contentType: false
          cache: false
          converters:
            'text xml': String
        ajax_deferred.done (ajaxData)->
          model.set
            loading_similarity_map: false
            similarity_map_base64_img: 'data:image/svg+xml;base64,'+btoa(ajaxData)
            reference_smiles_error: false
            reference_smiles_error_jqxhr: undefined
          ,
            silent: true

          model.trigger glados.Events.Compound.SIMILARITY_MAP_READY
          resolve(ajaxData)
        ajax_deferred.fail (jqxhrError)->
          reject(jqxhrError)
    promise = new Promise(promiseFunc)
    promise.then null, (jqxhrError)->
      model.set
        download_similarity_map_error: true
        loading_similarity_map: false
        reference_smiles_error: true
        reference_smiles_error_jqxhr: jqxhrError
      ,
        silent: true

      model.trigger glados.Events.Compound.SIMILARITY_MAP_ERROR
    return promise

  #---------------------------------------------------------------------------------------------------------------------
  # Highlighting
  #---------------------------------------------------------------------------------------------------------------------

  downloadAlignedSDF: ()->
    @set
#      'reference_smiles_error': false
      'download_aligned_error': false
    ,
      silent: true
    model = @
    promiseFunc = (resolve, reject)->
      referenceCTAB = model.get('reference_ctab')
      sdf2DData = model.get('sdf2DData')
      if not referenceCTAB?
        reject('Error, the reference CTAB is not present!')
        return
      if not sdf2DData?
        reject('Error, the compound '+model.get('molecule_chembl_id')+' CTAB is not present!')
        return

      if model.get('aligned_sdf')?
        resolve(model.get('aligned_sdf'))
      else
        formData = new FormData()
        sdf2DData = sdf2DData+'$$$$\n'
        templateBlob = new Blob([referenceCTAB], {type: 'chemical/x-mdl-molfile'})
        ctabBlob = new Blob([sdf2DData+sdf2DData], {type: 'chemical/x-mdl-sdfile'})
        formData.append('template', templateBlob, 'pattern.mol')
        formData.append('ctab', ctabBlob, 'mcs.sdf')
        formData.append('force', 'true')
        ajax_deferred = $.post
          url: Compound.SDF_2D_ALIGN_URL
          data: formData
          enctype: 'multipart/form-data'
          processData: false
          contentType: false
          cache: false
        ajax_deferred.done (ajaxData)->
          alignedSdf = ajaxData.split('$$$$')[0]+'$$$$\n'
          if alignedSdf.includes('Wrong arguments')
            reject('Wrong arguments')
          model.set('aligned_sdf', alignedSdf)
          resolve(ajaxData)
        ajax_deferred.fail (jqxhrError)->
          reject(jqxhrError)
    promise = new Promise(promiseFunc)
    promise.then null, (jqxhrError)->
      console.error jqxhrError
      model.set
        'download_aligned_error': true
        'aligned_sdf': null
#        'reference_smiles_error': true
#      model.trigger glados.Events.Compound.STRUCTURE_HIGHLIGHT_ERROR
    return promise

  downloadHighlightedSVG: ()->
    @set
      'reference_smiles_error': false
      'download_highlighted_error': false
    ,
      silent: true
    model = @
    promiseFunc = (resolve, reject)->
      referenceSmarts = model.get('reference_smarts')
      # Tries to use the 2d sdf without alignment if the alignment failed
      if model.get('aligned_sdf')?
        alignedSdf = model.get('aligned_sdf')
      else
        alignedSdf = model.get('sdf2DData')
      if not referenceSmarts?
        reject('Error, the reference SMARTS is not present!')
        return
      if not alignedSdf?
        reject('Error, the compound '+model.get('molecule_chembl_id')+' ALIGNED CTAB is not present!')
        return

      if model.get('substructure_highlight_base64_img')?
        resolve(model.get('substructure_highlight_base64_img'))
      else
        formData = new FormData()
        formData.append('file', new Blob([alignedSdf], {type: 'chemical/x-mdl-molfile'}), 'aligned.mol')
        formData.append('smarts', referenceSmarts)
        formData.append('computeCoords', 0)
        formData.append('force', 'true')
        formData.append('sanitize', 0)
        ajax_deferred = $.post
          url: Compound.SDF_2D_HIGHLIGHT_URL
          data: formData
          enctype: 'multipart/form-data'
          processData: false
          contentType: false
          cache: false
          converters:
            'text xml': String
        ajax_deferred.done (ajaxData)->
          model.set
            loading_substructure_highlight: false
            substructure_highlight_base64_img: 'data:image/svg+xml;base64,'+btoa(ajaxData)
            reference_smiles_error: false
            reference_smiles_error_jqxhr: undefined
          ,
            silent: true
          model.trigger glados.Events.Compound.STRUCTURE_HIGHLIGHT_READY
          resolve(ajaxData)
        ajax_deferred.fail (jqxhrError)->
          reject(jqxhrError)
    promise = new Promise(promiseFunc)
    promise.then null, (jqxhrError)->
      model.set
        loading_substructure_highlight: false
        download_highlighted_error: true
        reference_smiles_error: true
        reference_smiles_error_jqxhr: jqxhrError
      model.trigger glados.Events.Compound.STRUCTURE_HIGHLIGHT_ERROR
    return promise

  #---------------------------------------------------------------------------------------------------------------------
  # 3D SDF
  #---------------------------------------------------------------------------------------------------------------------

  download2DSDF: ()->
    @set('sdf2DError', false, {silent: true})
    promiseFunc = (resolve, reject)->
      if @get('sdf2DData')?
        resolve(@get('sdf2DData'))
      else
        ajax_deferred = $.get(Compound.SDF_2D_URL + @get('molecule_chembl_id') + '.sdf')
        compoundModel = @
        ajax_deferred.done (ajaxData)->
          compoundModel.set('sdf2DData', ajaxData)
          resolve(ajaxData)
        ajax_deferred.fail (error)->
          compoundModel.set('sdf2DError', true)
          reject(error)
    return new Promise(promiseFunc.bind(@))

  download3DSDF: (endpointIndex)->
    @set('sdf3DError', false, {silent: true})
    data3DCacheName = 'sdf3DData_'+endpointIndex
    promiseFunc = (resolve, reject)->
      if not @get('sdf2DData')?
        error = 'Error, There is no 2D data for the compound '+@get('molecule_chembl_id')+'!'
        compoundModel.set('sdf3DError', true)
        console.error error
        reject(error)
      else if @get(data3DCacheName)?
        resolve(data3DCacheName)
      else
        formData = new FormData()
        molFileBlob = new Blob([@get('sdf2DData')], {type: 'chemical/x-mdl-molfile'})
        formData.append('file', molFileBlob, 'molecule.mol')

        ajaxRequestDict =
          url: Compound.SDF_3D_ENDPOINTS[endpointIndex].url
          data: formData
          enctype: 'multipart/form-data'
          processData: false
          contentType: false
          cache: false

        ajax_deferred = $.post ajaxRequestDict
        compoundModel = @
        ajax_deferred.done (ajaxData)->
          if ajaxData? and ajaxData.trim().length > 0
            compoundModel.set(data3DCacheName, ajaxData)
            resolve(ajaxData)
          else
            compoundModel.set('sdf3DError', true)
            reject()

        ajax_deferred.fail (error)->
          compoundModel.set('sdf3DError', true)
          reject()
    return new Promise(promiseFunc.bind(@))

  download3DXYZ: (endpointIndex)->
    @set('xyz3DError', false, {silent: true})
    dataVarName = 'sdf3DDataXYZ_'+endpointIndex
    data3DSDFVarName = 'sdf3DData_'+endpointIndex
    promiseFunc = (resolve, reject)->
      if not @get('current3DData')?
        error = 'Error, There is no 3D data for the compound '+@get('molecule_chembl_id')+'!'
        compoundModel.set('xyz3DError', true)
        console.error error
        reject(error)
      else if @get(dataVarName)?
        resolve(dataVarName)
      else
        formData = new FormData()
        formData.append('file', new Blob([@get(data3DSDFVarName)], {type: 'chemical/x-mdl-molfile'}), 'aligned.mol')
        formData.set('computeCoords', 0)

        ajax_deferred = $.post
          url: Compound.SDF_3D_2_XYZ
          data: formData
          enctype: 'multipart/form-data'
          processData: false
          contentType: false
          cache: false
        compoundModel = @
        ajax_deferred.done (ajaxData)->
          compoundModel.set(dataVarName, ajaxData)
          resolve(ajaxData)
        ajax_deferred.fail (error)->
          compoundModel.set('xyz3DError', true)
          reject()
    return new Promise(promiseFunc.bind(@))


  calculate3DSDFAndXYZ: (endpointIndex)->
    @set
      cur3DEndpointIndex: endpointIndex
      current3DData: null
      current3DXYZData: null
    @trigger 'change:current3DData'
    @trigger 'change:current3DXYZData'
    dataVarName = 'sdf3DData_'+endpointIndex
    dataXYZVarName = 'sdf3DDataXYZ_'+endpointIndex

    after3DDownload = ()->
      @set('current3DData', @get(dataVarName))
      afterXYZDownload = ()->
        @set('current3DXYZData', @get(dataXYZVarName))
      @download3DXYZ(endpointIndex).then afterXYZDownload.bind(@)
    after3DDownload = after3DDownload.bind(@)

    download3DPromise = @download3DSDF.bind(@, endpointIndex)
    @download2DSDF().then ()->
      download3DPromise().then(after3DDownload)

  #---------------------------------------------------------------------------------------------------------------------
  # instance urls
  #---------------------------------------------------------------------------------------------------------------------
  getSimilaritySearchURL: (threshold=glados.Settings.DEFAULT_SIMILARITY_THRESHOLD) ->

    glados.Settings.SIMILARITY_URL_GENERATOR
      term: @get('id')
      threshold: threshold

#-----------------------------------------------------------------------------------------------------------------------
# 3D SDF Constants
#-----------------------------------------------------------------------------------------------------------------------

Compound.SDF_2D_ALIGN_URL = glados.Settings.BEAKER_BASE_URL + 'align'
Compound.SDF_2D_HIGHLIGHT_URL = glados.Settings.BEAKER_BASE_URL + 'highlightCtabFragmentSvg'
Compound.SDF_2D_URL = glados.Settings.WS_BASE_URL + 'molecule/'
Compound.SDF_3D_2_XYZ = glados.Settings.BEAKER_BASE_URL + 'ctab2xyz'
Compound.SMILES_2_SIMILARITY_MAP_URL = glados.Settings.BEAKER_BASE_URL + 'smiles2SimilarityMap'
Compound.SDF_3D_ENDPOINTS = [
  {
    label: 'UFF'
    url: glados.Settings.BEAKER_BASE_URL+ 'ctab23D'
  },
  {
    label: 'MMFF'
    url: glados.Settings.BEAKER_BASE_URL+ 'MMFFctab23D'
  },
  {
    label: 'ETKDG'
    url: glados.Settings.BEAKER_BASE_URL+ 'ETKDGctab23D'
  },
  {
    label: 'KDG'
    url: glados.Settings.BEAKER_BASE_URL+ 'KDGctab23D'
  }
]

# Constant definition for ReportCardEntity model functionalities
_.extend(Compound, glados.models.base.ReportCardEntity)
Compound.color = 'cyan'
Compound.reportCardPath = 'compound_report_card/'

Compound.getSDFURL = (chemblId) -> glados.Settings.WS_BASE_URL + 'molecule/' + chemblId + '.sdf'

Compound.INDEX_NAME = 'chembl_molecule'

Compound.PROPERTIES_VISUAL_CONFIG = {
  'molecule_chembl_id': {
    link_base: 'report_card_url'
    image_base_url: 'image_url'
    hide_label: true
  },
  'molecule_synonyms': {
    parse_function: (values) -> _.uniq(v.molecule_synonym for v in values).join(', ')
  },
  '_metadata.related_targets.count': {
    format_as_number: true
    link_base: 'targets_url'
    on_click: CompoundReportCardApp.initMiniHistogramFromFunctionLink
    function_parameters: ['molecule_chembl_id']
    function_constant_parameters: ['targets']
    function_key: 'targets'
    function_link: true
    execute_on_render: true
    format_class: 'number-cell-center'
  },
  '_metadata.related_activities.count': {
    link_base: 'activities_url'
    on_click: CompoundReportCardApp.initMiniHistogramFromFunctionLink
    function_parameters: ['molecule_chembl_id']
    function_constant_parameters: ['activities']
    # to help bind the link to the function, it could be necessary to always use the key of the columns descriptions
    # or probably not, depending on how this evolves
    function_key: 'bioactivities'
    function_link: true
    execute_on_render: true
    format_class: 'number-cell-center'
  },
  'similarity': {
      'show': true
      'comparator': '_context.similarity'
      'sort_disabled': false
      'is_sorting': 0
      'sort_class': 'fa-sort'
      'is_contextual': true
  }
}

Compound.COLUMNS = {
  CHEMBL_ID: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_chembl_id'
    link_base: 'report_card_url'
    image_base_url: 'image_url'
    hide_label: true
  SYNONYMS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_synonyms'
    parse_function: (values) -> _.uniq(v.molecule_synonym for v in values).join(', ')
  PREF_NAME: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'pref_name'
  MOLECULE_TYPE: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_type'
  MAX_PHASE: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'max_phase'
  DOSED_INGREDIENT: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: 'Dosed Ingredient'
    comparator: 'dosed_ingredient'
  SIMILARITY_ELASTIC: {
      'show': true
      'name_to_show': 'Similarity'
      'comparator': '_context.similarity'
      'sort_disabled': false
      'is_sorting': 0
      'sort_class': 'fa-sort'
      'is_contextual': true
    }
  STRUCTURE_TYPE: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'structure_type'
  INORGANIC_FLAG: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'inorganic_flag'
  FULL_MWT: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.full_mwt'
  FULL_MWT_CARD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: 'MWt'
    comparator: 'molecule_properties.full_mwt'
  ALOGP: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.alogp'
  HBA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.hba'
  HBD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.hbd'
  HEAVY_ATOMS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.heavy_atoms'
  PSA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.psa'
  RO5: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.num_ro5_violations'
  RO5_CARD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: '#RO5'
    comparator: 'molecule_properties.num_ro5_violations'
  ROTATABLE_BONDS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.rtb'
  ROTATABLE_BONDS_CARD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: '#RTB'
    comparator: 'molecule_properties.rtb'
  RULE_OF_THREE_PASS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.ro3_pass'
  RULE_OF_THREE_PASS_CARD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: 'Passes Rule of Three'
    comparator: 'molecule_properties.ro3_pass'
  QED_WEIGHTED: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.qed_weighted'
  APKA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.acd_most_apka'
  BPKA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.acd_most_bpka'
  ACD_LOGP: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.acd_logp'
  ACD_LOGD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.acd_logd'
  AROMATIC_RINGS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.aromatic_rings'
  HBA_LIPINSKI: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.hba_lipinski'
  HBD_LIPINSKI: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.hbd_lipinski'
  RO5_LIPINSKI: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.num_lipinski_ro5_violations'
  MWT_MONOISOTOPIC: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.mw_monoisotopic'
  MOLECULAR_SPECIES: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.molecular_species'
  FULL_MOLFORMULA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.full_molformula'
  NUM_TARGETS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: '_metadata.related_targets.count'
    format_as_number: true
    link_base: 'targets_url'
    on_click: CompoundReportCardApp.initMiniHistogramFromFunctionLink
    function_parameters: ['molecule_chembl_id']
    function_constant_parameters: ['targets']
    function_key: 'targets'
    function_link: true
    execute_on_render: true
    format_class: 'number-cell-center'
  NUM_TARGETS_BY_CLASS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: 'Targets (by Class)'
    comparator: '_metadata.related_targets.count'
    format_as_number: true
    link_base: 'targets_url'
    on_click: CompoundReportCardApp.initMiniHistogramFromFunctionLink
    function_parameters: ['molecule_chembl_id']
    function_constant_parameters: ['targets_by_class']
    function_key: 'compound_targets_by_class'
    function_link: true
    execute_on_render: true
    format_class: 'number-cell-center'
  BIOACTIVITIES_NUMBER: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: '_metadata.related_activities.count'
    link_base: 'activities_url'
    on_click: CompoundReportCardApp.initMiniHistogramFromFunctionLink
    function_parameters: ['molecule_chembl_id']
    function_constant_parameters: ['activities']
    # to help bind the link to the function, it could be necessary to always use the key of the columns descriptions
    # or probably not, depending on how this evolves
    function_key: 'bioactivities'
    function_link: true
    execute_on_render: true
    format_class: 'number-cell-center'
  COMPOUND_SOURCES_LIST: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    # this should be generated automatically
    id: 'compound_sources_list'
    comparator: '_metadata.compound_records'
    name_to_show: 'Compound Sources'
    parse_function: (values) -> _.unique(v.src_description for v in values)
  ADDITIONAL_SOURCES_LIST: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    id: 'additional_sources_list'
    comparator: '_metadata.compound_records'
    name_to_show_function: (model) ->

      switch model.isParent()
        when true then return 'Additional Sources From Alternate Forms:'
        when false then return 'Additional Sources From Parent:'

    col_value_function: (model) -> model.getAdditionalSources()
    show_function: (model) -> model.hasAdditionalSources()
  WITHDRAWN_YEAR: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'withdrawn_year'
  WITHDRAWN_COUNTRY: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'withdrawn_country'
  WITHDRAWN_REASON: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'withdrawn_reason'
  WITHDRAWN_CLASS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'withdrawn_class'
  HELM_NOTATION: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'helm_notation'
  BIOCOMPONENTS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'biotherapeutic.biocomponents'
}


Compound.COLUMNS.CHEMBL_ID = {
  aggregatable: true
  comparator: "molecule_chembl_id"
  hide_label: true
  id: "molecule_chembl_id"
  image_base_url: "image_url"
  is_sorting: 0
  link_base: "report_card_url"
  name_to_show: "ChEMBL ID"
  name_to_show_short: "ChEMBL ID"
  show: true
  sort_class: "fa-sort"
  sort_disabled: false
}

Compound.ID_COLUMN = Compound.COLUMNS.CHEMBL_ID

Compound.COLUMNS_SETTINGS = {
  ALL_COLUMNS: (->
    colsList = []
    for key, value of Compound.COLUMNS
      colsList.push value
    return colsList
  )()
  RESULTS_LIST_TABLE: [
    Compound.COLUMNS.CHEMBL_ID,
  ]
#  RESULTS_LIST_TABLE: [
#    Compound.COLUMNS.CHEMBL_ID,
#    Compound.COLUMNS.PREF_NAME
#    Compound.COLUMNS.SYNONYMS,
#    Compound.COLUMNS.MOLECULE_TYPE,
#    Compound.COLUMNS.MAX_PHASE,
#    Compound.COLUMNS.FULL_MWT,
#    Compound.COLUMNS.NUM_TARGETS,
#    Compound.COLUMNS.BIOACTIVITIES_NUMBER,
#    Compound.COLUMNS.ALOGP,
#    Compound.COLUMNS.PSA,
#    Compound.COLUMNS.HBA,
#    Compound.COLUMNS.HBD,
#    Compound.COLUMNS.RO5,
#    Compound.COLUMNS.ROTATABLE_BONDS,
#    Compound.COLUMNS.RULE_OF_THREE_PASS,
#    Compound.COLUMNS.QED_WEIGHTED
#  ]
  RESULTS_LIST_TABLE_SIMILARITY: [
    Compound.COLUMNS.SIMILARITY_ELASTIC
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME
    Compound.COLUMNS.SYNONYMS,
    Compound.COLUMNS.MOLECULE_TYPE,
    Compound.COLUMNS.MAX_PHASE,
    Compound.COLUMNS.FULL_MWT,
    Compound.COLUMNS.NUM_TARGETS,
    Compound.COLUMNS.BIOACTIVITIES_NUMBER,
    Compound.COLUMNS.ALOGP,
    Compound.COLUMNS.PSA,
    Compound.COLUMNS.HBA,
    Compound.COLUMNS.HBD,
    Compound.COLUMNS.RO5,
    Compound.COLUMNS.ROTATABLE_BONDS,
    Compound.COLUMNS.RULE_OF_THREE_PASS,
    Compound.COLUMNS.QED_WEIGHTED
  ]
  RESULTS_LIST_REPORT_CARD:[
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME
  ]
  RESULTS_LIST_REPORT_CARD_SIMILARITY:[
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME,
    Compound.COLUMNS.SIMILARITY_ELASTIC
  ]
  RESULTS_LIST_REPORT_CARD_LONG:[
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME,
    Compound.COLUMNS.MAX_PHASE,
    Compound.COLUMNS.FULL_MWT,
    Compound.COLUMNS.ALOGP
  ]
  MINI_REPORT_CARD:[
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME,
    Compound.COLUMNS.SYNONYMS,
    Compound.COLUMNS.MAX_PHASE,
    Compound.COLUMNS.FULL_MWT,
    Compound.COLUMNS.ALOGP,
    Compound.COLUMNS.PSA,
    Compound.COLUMNS.HBA,
    Compound.COLUMNS.HBD,
    Compound.COLUMNS.RO5,
    Compound.COLUMNS.NUM_TARGETS,
    Compound.COLUMNS.BIOACTIVITIES_NUMBER
  ]
  RESULTS_LIST_REPORT_CARD_ADDITIONAL:[
    Compound.COLUMNS.PREF_NAME
  ]
#  RESULTS_LIST_REPORT_CARD_ADDITIONAL:[
#    Compound.COLUMNS.APKA,
#    Compound.COLUMNS.BPKA,
#    Compound.COLUMNS.ACD_LOGP,
#    Compound.COLUMNS.ACD_LOGD,
#    Compound.COLUMNS.AROMATIC_RINGS,
#    Compound.COLUMNS.STRUCTURE_TYPE,
#    Compound.COLUMNS.INORGANIC_FLAG,
#    Compound.COLUMNS.HEAVY_ATOMS,
#    Compound.COLUMNS.HBA_LIPINSKI,
#    Compound.COLUMNS.HBD_LIPINSKI,
#    Compound.COLUMNS.RO5_LIPINSKI,
#    Compound.COLUMNS.MWT_MONOISOTOPIC,
#    Compound.COLUMNS.MOLECULAR_SPECIES,
#    Compound.COLUMNS.FULL_MOLFORMULA,
##    Compound.COLUMNS.NUM_TARGETS_BY_CLASS
#  ]
  RESULTS_LIST_SIMILARITY:[
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.SIMILARITY,
    Compound.COLUMNS.MOLECULE_TYPE,
    Compound.COLUMNS.PREF_NAME,
  ]
  RESULTS_LIST_REPORT_CARD_CAROUSEL: [
    Compound.COLUMNS.CHEMBL_ID
  ]
  TEST: [
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME
    Compound.COLUMNS.MAX_PHASE,
  ]
  COMPOUND_SOURCES_SECTION: [
    Compound.COLUMNS.COMPOUND_SOURCES_LIST
    Compound.COLUMNS.ADDITIONAL_SOURCES_LIST
  ]
  WITHDRAWN_INFO_SECTION: [
    Compound.COLUMNS.WITHDRAWN_YEAR
    Compound.COLUMNS.WITHDRAWN_COUNTRY
    Compound.COLUMNS.WITHDRAWN_REASON
    Compound.COLUMNS.WITHDRAWN_CLASS
  ]
  HELM_NOTATION_SECTION: [
    Compound.COLUMNS.CHEMBL_ID
    Compound.COLUMNS.HELM_NOTATION
  ]
  BIOCOMPONENTS_SECTION: [
    Compound.COLUMNS.CHEMBL_ID
    Compound.COLUMNS.BIOCOMPONENTS
  ]
  CLINICAL_DATA_SECTION:[
    _.extend Compound.COLUMNS.PREF_NAME,
      additional_parsing:
        encoded_value: (value) -> value.replace(/[ ]/g, '+')
    _.extend {}, Compound.COLUMNS.SYNONYMS,
      parse_from_model: true
      additional_parsing:
        search_term: (model) ->
          synonyms = if model.isParent() then model.getOwnAndAdditionalSynonyms() else model.getSynonyms()
          tradenames = if model.isParent() then model.getOwnAndAdditionalTradenames() else model.getTradenames()
          fullList = _.union(synonyms, tradenames)
          linkText = _.uniq(v for v in fullList).join(' OR ')

          maxTextLength = 100
          if linkText.length > maxTextLength
            linkText = "#{linkText.substring(0, (maxTextLength-3))}..."

          return linkText
        encoded_search_term: (model) ->
          synonyms = if model.isParent() then model.getOwnAndAdditionalSynonyms() else model.getSynonyms()
          tradenames = if model.isParent() then model.getOwnAndAdditionalTradenames() else model.getTradenames()
          fullList = _.union(synonyms, tradenames)
          return encodeURIComponent(_.uniq(v for v in fullList).join(' OR '))

  ]
}

Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS = _.union(Compound.COLUMNS_SETTINGS.RESULTS_LIST_TABLE,
  Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL)

Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS_SIMILARITY = _.union(
  Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS,
  [Compound.COLUMNS.SIMILARITY_ELASTIC])

Compound.MINI_REPORT_CARD =
  LOADING_TEMPLATE: 'Handlebars-Common-MiniRepCardPreloader'
  TEMPLATE: 'Handlebars-Common-MiniReportCard'
  COLUMNS: Compound.COLUMNS_SETTINGS.MINI_REPORT_CARD

Compound.getCompoundsListURL = (filter, isFullState=false, fragmentOnly=false) ->

  if isFullState
    filter = btoa(JSON.stringify(filter))

  return glados.Settings.ENTITY_BROWSERS_URL_GENERATOR
    fragment_only: fragmentOnly
    entity: 'compounds'
    filter: encodeURIComponent(filter) unless not filter?
    is_full_state: isFullState