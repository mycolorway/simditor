
class Uploader extends Module

  @count: 0

  opts:
    url: ''
    params: null
    connectionCount: 3
    leaveConfirm: '正在上传文件，如果离开上传会自动取消'

  files: [] #files being uploaded

  queue: [] #files waiting to be uploaded

  html5: !!(window.File && window.FileList)

  constructor: (opts = {}) ->
    $.extend(@opts, opts)
    @id = ++ Uploader.count

    # upload the files in the queue
    @on 'uploadcomplete', (e, file) =>
      @files.splice($.inArray(file, @files), 1)
      if @queue.length > 0 and @files.length < @opts.connectionCount
        @upload @queue.shift()
      else
        @uploading = false

    # confirm to leave page while uploading
    $(window).on 'beforeunload.uploader-' + @id, (e) =>
      return unless @uploading

      # for ie
      # TODO firefox can not set the string
      e.originalEvent.returnValue = @opts.leaveConfirm
      # for webkit
      return @opts.leaveConfirm

  generateId: (->
    id = 0
    return ->
      id += 1
  )()

  upload: (file, opts = {}) ->
    return unless file?

    if $.isArray file
      @upload(f, opts) for f in file
    else if $(file).is('input:file') and @html5
      @upload($.makeArray($(file)[0].files), opts)
    else if !file.id or !file.obj
      file = @getFile file

    return unless file and file.obj

    $.extend(file, opts)

    if @files.length >= @opts.connectionCount
      @queue.push file
      return

    return if @triggerHandler('beforeupload', [file]) == false

    @files.push file
    if @html5
      @xhrUpload file
    else
      @iframeUpload file

    @uploading = true

  getFile: (fileObj) ->
    if fileObj instanceof window.File
      name = fileObj.fileName ? fileObj.name
    else if $(fileObj).is('input:file')
      name = $input.val().replace(/.*(\/|\\)/, "")
      fileObj = $(fileObj).clone()
    else
      return null

    id: @generateId()
    url: @opts.url
    params: @opts.params
    name: name
    size: fileObj.fileSize ? fileObj.size
    ext: if name then name.split('.').pop().toLowerCase() else ''
    obj: fileObj

  xhrUpload: (file) ->
    formData = new FormData()
    formData.append("upload_file", file.obj)
    formData.append("original_filename", file.name)
    formData.append(k, v) for k, v of file.params if file.params

    file.xhr = $.ajax
      url: file.url
      data: formData
      processData: false
      contentType: false
      type: 'POST'
      headers:
        'X-File-Name': encodeURIComponent(file.name)
      xhr: ->
        req = $.ajaxSettings.xhr()
        if req
          req.upload.onprogress = (e) =>
            @progress(e)
        req
      progress: (e) =>
        return unless e.lengthComputable
        @trigger 'uploadprogress', [file, e.loaded, e.total]
      error: (xhr, status, err) =>
        @trigger 'uploaderror', [file, xhr, status]
      success: (result) =>
        @trigger 'uploadprogress', [file, file.size, file.size]
        @trigger 'uploadsuccess', [file, result]
      complete: (xhr, status) =>
        @trigger 'uploadcomplete', [file, $.parseJSON(xhr.responseText)]

  iframeUpload: (file) ->
    file.iframe = $('iframe', {
      src: 'javascript:false;',
      name: 'uploader-' + file.id
    }).hide()
      .appendTo(document.body)

    file.form = $('<form/>', {
      method: 'post',
      enctype: 'multipart/form-data',
      action: file.url,
      target: file.iframe[0].name
    }).hide()
      .append(file.obj)
      .appendTo(document.body)

    if file.params
      for k, v of file.params
        $('<input/>', {
          type: 'hidden',
          name: k,
          value: v
        }).appendTo(form)

    file.iframe.on 'load', =>
      # when we remove iframe from dom
      # the request stops, but in IE load
      # event fires
      return unless iframe.parent().length > 0

      iframeDoc = iframe[0].contentDocument

      # In Opera event is fired second time
      # when body.innerHTML changed from false
      # to server response approx. after 1 sec
      # when we upload file with iframe
      return if iframeDoc and iframeDoc.body and iframeDoc.body.innerHTML == "false"

      # 当返回的JSON中存在html片段时，需要做这个hack
      # json-response是一个script标签
      # TODO: 简化服务器端的操作
      responseEl = iframeDoc.getElementById('json-response')
      json = if responseEl then responseEl.innerHTML else iframeDoc.body.innerHTML

      try
        result = $.parseJSON json
      catch error
        @trigger 'uploaderror', [file, null, 'parsererror']
        result = {}

      if result.success
        @trigger 'uploadsuccess', [file, result]

      @trigger 'uploadcomplete', [file, result]
      file.iframe.remove()

    file.form.submit().remove()

  cancel: (file) ->
    unless file.id
      for f in @files
        if f.id == file
          file = f
          break

    @trigger 'uploadcancel', [file]

    if @html5
      # abort xhr will trigger complete event automatically
      file.xhr.abort() if file.xhr
      file.xhr = null
    else
      file.iframe
        .attr('src', 'javascript:false;')
        .remove()
      @trigger 'uploadcomplete', [file]

  readImageFile: (fileObj, callback) ->
    return unless $.isFunction callback

    img = new Image()
    img.onload = ->
      callback img
    img.onerror = ->
      callback()

    if window.FileReader && FileReader.prototype.readAsDataURL && /^image/.test(fileObj.type)
      fileReader = new FileReader()
      fileReader.onload = (e) ->
        img.src = e.target.result
      fileReader.readAsDataURL fileObj
    else
      callback()

  destroy: ->
    @queue.length = 0
    @cancel file for file in @files
    $(window).off '.uploader-' + @id
    $(document).off '.uploader-' + @id



window.Uploader = Uploader




