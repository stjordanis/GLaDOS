glados.useNameSpace 'glados.models.paginatedCollections.SpecificFlavours',

  UnichemConnectivityRefsList:

    setCompound: (compound) -> @setMeta('original_compound', compound)
    setInchiKeys: (keysStructure) -> @setMeta('keys_structure', keysStructure)
    getURLForInchi: (inchiKey) ->

      uCBKey = glados.models.paginatedCollections.SpecificFlavours.UnichemConnectivityRefsList.UNICHEM_CALLBACK_KEY
      return "#{glados.ChemUtils.UniChem.connectivity_url}#{encodeURI(inchiKey)}/0/0/4?callback=#{uCBKey}"

    #-------------------------------------------------------------------------------------------------------------------
    # Fetching
    #-------------------------------------------------------------------------------------------------------------------
    fetch: ->
      keysStructure = @getMeta('keys_structure')
      parentInchiKey = keysStructure.parent_key
      @fetchDataForInchiKey(parentInchiKey)

    fetchDataForInchiKey: (inchiKey) ->

      thisList = @
      callbackUnichem = (ucJSONResponse) ->

        thisList.reset(thisList.parse(ucJSONResponse))
        # replace with items ready thing!!!

      uCBKey = glados.models.paginatedCollections.SpecificFlavours.UnichemConnectivityRefsList.UNICHEM_CALLBACK_KEY
      window[uCBKey] = callbackUnichem

      jQueryPromise = $.ajax
        type: 'GET'
        url: @getURLForInchi(inchiKey)
        jsonp: uCBKey
        dataType: 'jsonp'
        headers:
          'Accept':'application/json'

    #-------------------------------------------------------------------------------------------------------------------
    # Parsing
    #-------------------------------------------------------------------------------------------------------------------
    parse: (response) ->

      matchesSourcesReceived = response[1]
      parsedSourcesWithMatches = []
      for source in matchesSourcesReceived

        baseItemURL = source.base_id_url

        matches = source.src_matches
        identicalMatches = []
        sMatches = []
        pMatches = []
        iMatches = []
        ipMatches = []
        spMatches = []
        siMatches = []
        sipMatches = []

        for match in matches

          srcCompoundID = match.src_compound_id
          matchURL = baseItemURL + srcCompoundID

          for compare in match.match_compare

            newRef =
              ref_url: matchURL
              ref_id: srcCompoundID

            # this logic has been copied from https://github.com/chembl/chembl_interface/blob/master/system/application/views/application/compound/report_card/unichem_connectivity.php
            isS = (parseInt(compare.b) == 1 or parseInt(compare.m) == 1 \
            or parseInt(compare.s) == 1 or parseInt(compare.t) == 1)

            isI = parseInt(compare.i) == 1
            isP = parseInt(compare.p) == 1

            switch
              when (isS and isI and isP) then sipMatches.push(newRef)
              when (isS and isI) then siMatches.push(newRef)
              when (isS and isP) then spMatches.push(newRef)
              when (isI and isP) then ipMatches.push(newRef)
              when (isI) then iMatches.push(newRef)
              when (isP) then pMatches.push(newRef)
              when (isS) then sMatches.push(newRef)
              else identicalMatches.push(newRef)


        parsedSourcesWithMatches.push
          src_name: source.name_label
          scr_url: source.src_URL
          identical_matches: identicalMatches
          s_matches: sMatches
          p_matches: pMatches
          i_matches: iMatches
          ip_matches: ipMatches
          sp_matches: spMatches
          si_matches: siMatches
          sip_matches: sipMatches


      return parsedSourcesWithMatches



glados.models.paginatedCollections.SpecificFlavours.UnichemConnectivityRefsList.UNICHEM_CALLBACK_KEY = 'UNICHEM_CALLBACK'
