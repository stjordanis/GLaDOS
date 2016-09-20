DownloadModelExt =

  getBlobToDownload: (contentStr, contentType) ->

    contentType = 'text/plain;charset=utf-8' unless contentType?
    return new Blob([contentStr], type: contentType)

  # This function returns the object that is going to be used to
  # generate the download, The download object is a javascript object with the structure required from the download
  # for example, to download a compound, the download object will be something like:
  #
  # [{"molecule_chembl_id":"CHEMBL25",
  # "atc_classifications":["N02BA01","N02BA51","N02BA71","A01AD05","B01AC06"],
  # "availability_type":"2",
  # "biotherapeutic":null,
  # "black_box_warning":"0","chebi_par_id":15365,"chirality":"1",
  # ...}]
  # and the download functions will take care of handling it in order to generate the file
  #
  # Note that this is a list of objects! because you can download only one item (one compound) or a list of items
  # (a list of compounds)
  #
  # if there is no special download parser
  # function, the object will be simply the object's attributes
  getDownloadObject: (downloadParserFunction) ->

    if !downloadParserFunction?
      return @attributes
    else
      return downloadParserFunction @attributes

  # --------------------------------------------------------------------
  # CSV
  # --------------------------------------------------------------------

  getCSVHeaderString: (downloadObject) ->

    keys = []
    for key, value of downloadObject
      keys.push(key)

    return keys.join(';')

  getCSVContentString: (downloadObject) ->

    values = []
    for key, value of downloadObject
      values.push(JSON.stringify(downloadObject[key]))

    return values.join(';')

  getFullCSVString: (downloadObject) ->

    header = @getCSVHeaderString(downloadObject)
    content = @getCSVContentString(downloadObject)
    return header + '\n' + content

  downloadCSV: (filename, downloadParserFunction) ->

    downloadObject = @getDownloadObject(downloadParserFunction)
    strContent = @getFullCSVString(downloadObject)
    blob = @getBlobToDownload strContent
    saveAs blob, filename

    return strContent

  # --------------------------------------------------------------------
  # json
  # --------------------------------------------------------------------

  getJSONString: (downloadObject) ->

    JSON.stringify(downloadObject)


  # the download parser function determines what to to with the model's
  # attributes to generate the object that is going to be used for
  # generating the download.
  downloadJSON: (filename, downloadParserFunction) ->

    downloadObject = @getDownloadObject(downloadParserFunction)
    strContent = @getJSONString(downloadObject)
    blob = @getBlobToDownload strContent
    saveAs blob, filename

    return strContent

  # --------------------------------------------------------------------
  # xls
  # --------------------------------------------------------------------

  getXLSString: (downloadObject) ->

    Workbook = ->
      if !(this instanceof Workbook)
        return new Workbook
      @SheetNames = []
      @Sheets = {}
      return

    wb = new Workbook()
    wb.SheetNames.push('sheet1')

    ws = {}

    # add header row
    currentRow = 0
    currentColumn = 0
    for key, value of downloadObject

      cellNumber = XLSX.utils.encode_cell({c:currentColumn, r:currentRow})
      cellContent = {v: key, t:'s' } # t is the type, for now everything is a string
      ws[cellNumber] = cellContent

      currentColumn++

    # add data row
    currentRow++
    currentColumn = 0
    for key, value of downloadObject

      cellNumber = XLSX.utils.encode_cell({c:currentColumn, r:currentRow})
      if value?
       cellVal = value
      else
        cellVal = '---'

      cellContent = {v: String(cellVal), t:'s' }
      ws[cellNumber] = cellContent

      currentColumn++

    range = {s: {c:0, r:0}, e: {c:currentColumn - 1 , r:currentRow }}

    ws['!ref'] = XLSX.utils.encode_range(range)

    wb.Sheets['sheet1'] = ws


    wbout = XLSX.write(wb, {bookType:'xlsx', bookSST:true, type: 'binary'})

    s2ab = (s) ->
      buf = new ArrayBuffer(s.length)
      view = new Uint8Array(buf)
      i = 0
      while i != s.length
        view[i] = s.charCodeAt(i) & 0xFF
        ++i
      buf

    return s2ab(wbout)


  downloadXLS: (filename, downloadParserFunction) ->

    downloadObject = @getDownloadObject(downloadParserFunction)
    strContent = @getXLSString(downloadObject)

    blob = @getBlobToDownload strContent, 'application/octet-stream'
    saveAs blob, filename

    ab2s= (buf) ->
      String.fromCharCode.apply(null, new Uint8Array(buf));

    return ab2s(strContent)
