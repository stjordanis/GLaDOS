DocumentAssayNetwork = Backbone.Model.extend

  fetch: ->
    docChemblId = @get('document_chembl_id')

    assaysUrl = 'https://www.ebi.ac.uk/chembl/api/data/assay.json?document_chembl_id=' + docChemblId + '&limit=1000'

    allAssays = {}

    #this is to know when I finished to get all activities
    activitiesListsRequested = 0
    activitiesListsReceived = 0

    # 1. Get all the Assays from the document chembl id, in some cases it needs to iterate over the pagination
    # because there are too many, for example CHEMBL2766011
    triggerAssayRequest = (currentUrl) ->
      getAssaysGroup = $.getJSON currentUrl, (response) ->
        newAssays = response.assays

        $.each newAssays, (index, newAssay) ->
          allAssays[newAssay.assay_chembl_id] = newAssay
          currentActsUrl = 'https://www.ebi.ac.uk/chembl/api/data/activity.json?assay_chembl_id=' + newAssay.assay_chembl_id + '&limit=1000'
          activitiesListsRequested++
          console.log 'num activities lists requested: ', activitiesListsRequested
          triggerActivityRequest(currentActsUrl)

        nextUrl = response.page_meta.next

        if nextUrl?
          triggerAssayRequest('https://www.ebi.ac.uk' + nextUrl)
        # if there is no next I must have processed the last page
        else
          console.log 'ALL ASSAYS OBTAINED'
          console.log allAssays
          console.log _.pluck(allAssays, 'assay_chembl_id')


      getAssaysGroup.fail ->
        console.log 'FAILED getting assays list!'

    triggerAssayRequest(assaysUrl)


    #
    # 2. For each assay that I receive in the previous function, I trigger a retrieval of the activities.
    #
    triggerActivityRequest = (currentActsUrl) ->
      console.log 'requesting activities: ', currentActsUrl

      getActivityGroup = $.getJSON currentActsUrl, (response) ->
        newActivities = response.activities

        $.each newActivities, (index, newActivity) ->
          console.log 'new activity from assay: ', newActivity.assay_chembl_id, ' to molecule: ', newActivity.molecule_chembl_id
          currentAssay = allAssays[newActivity.assay_chembl_id]

          currentAssay.compound_act_list = {} unless currentAssay.compound_act_list?
          currentAssay.compound_act_list[newActivity.molecule_chembl_id] = 1


        nextUrl = response.page_meta.next

        if nextUrl?
          triggerActivityRequest('https://www.ebi.ac.uk' + nextUrl)
          console.log 'requesting more activities'
        else
          activitiesListsReceived++
          console.log 'num lists received: ', activitiesListsReceived
          checkIfAllInfoReady()

      getActivityGroup.fail ->
        console.log 'FAILED activities list!'

    # here I check if I got all the information I need
    # after this it what is required is to reorganise it to create the graphs
    # no more calls to the web services
    links = []
    checkIfAllInfoReady = () ->

      if activitiesListsRequested == activitiesListsReceived
        console.log 'ALL READY!'
        console.log allAssays

        i = 0
        $.each allAssays, (objIndex, assayI) ->

          console.log 'I: ', i
          compoundsI = assayI.compound_act_list

          j = 0
          $.each allAssays, (objIndex, assayJ) ->

            # the matrix is symmetric, don't do the computing twice
            if i > j
              return

            console.log 'J: ', j
            compoundsJ = assayJ.compound_act_list

            console.log 'comparing ', assayI.assay_chembl_id, ' with ', assayJ.assay_chembl_id
            console.log 'lists: ', compoundsI, ' , ', compoundsJ

            numEqual = 0
            for molecule_chembl_id, val of compoundsI
              if compoundsJ[molecule_chembl_id] == 1
                numEqual++

            links.push({"source":i, "target": j, "value":numEqual})
            console.log numEqual, ' are equal!'
            console.log '^^^^'

            j++

          i++



