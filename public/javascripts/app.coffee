# ----------------------------------------------------------------------------
# Log Search Server JS
# by John Tajima - modified by Adrian E. Madrid
# requires jQuery 1.3.2
# ----------------------------------------------------------------------------

window.Search =

  search_form: "search"                           # domId of the form
  resultsId: "results"                            # domId of the results table
  search_fields: [ "term1", "term2", "term3" ]    # domIds of search term fields
  file_list: "file-list"                          # domId of select for logfiles
  logfiles: {}                                    # hash of log files
  past_params: null                               # recent request
  url: "/perform"
  scroll_fnId: null

  # Initialize Search form
  # { 'grep': [ log, files, for, grep], 'tail': [ 'log', 'files', 'for', 'tail']}
  init: (logfiles, params) ->
    @logfiles = logfiles
    @past_params = params

    @bind_grep_tool()
    @bind_tail_tool()
    @bind_options()

    # return if no prev settings, nothing to set
    return unless @past_params

    # init tool selector
    (if (@past_params["tool"] == "grep") then $("#grep-label").trigger("click") else $("#tail-tool").trigger("click"))

    # init search fields
    $("#" + @file_list).val @past_params["file"]

    # init search fields
    jQuery.each @search_fields, ->
      $("#" + this).val Search.past_params[this]

    # advanced options usd?
    # time was set - so show advanced options
    if (@past_params["sh"]) or (@past_params["eh"])
      @showAdvanced()
      if @past_params["sh"]
        jQuery.each [ "sh", "sm", "ss" ], ->
          $("#" + this).val Search.past_params[this]
      if @past_params["eh"]
        jQuery.each [ "eh", "em", "es" ], ->
          $("#" + this).val Search.past_params[this]

  # bind option selectors
  bind_options: ->
    $("#auto-scroll").bind "change", ->
      Search.autoScroll @checked

    $("#auto-scroll").attr("checked", false).trigger "change"
    $("#auto-meta").bind "change", ->
      Search.autoMetaData @checked

    $("#auto-meta").attr("checked", true).trigger "change"
    $("#auto-datetime").bind "change", ->
      Search.autoDateTime @checked

    $("#auto-datetime").attr("checked", true).trigger "change"

  # bind change grep tool
  bind_grep_tool: ->
    $("#grep-tool").bind "change", (e) ->
      newlist = ""
      jQuery.each Search.logfiles["grep"], ->
        newlist += "<option value='" + this + "'>" + this + "</option>\n"

      $("#" + Search.file_list).html newlist

    $("#grep-label").bind "click", (e) ->
      $("#grep-tool").attr("checked", "checked").val("grep").trigger "change"

  # bind change tail tool
  bind_tail_tool: ->
    $("#tail-tool").bind "change", (e) ->
      newlist = ""
      jQuery.each Search.logfiles["tail"], ->
        newlist += "<option value='" + this + "'>" + this + "</option>\n"

      $("#" + Search.file_list).html newlist

    $("#tail-label").bind "click", (e) ->
      $("#tail-tool").attr("checked", "checked").val("tail").trigger "change"

  # clears the terms fields
  clear: ->
    jQuery.each @search_fields, ->
      $("#" + this).val ""

  showAdvanced: ->
    $("#enable-advanced").hide()
    $("#disable-advanced").show()
    $(".advanced-options").show()

  hideAdvanced: ->
    @clearAdvanced()
    $("#enable-advanced").show()
    $("#disable-advanced").hide()
    $(".advanced-options").hide()

  clearAdvanced: ->
    $("#advanced-options input").val ""

  # gathers form elements and submits to proper url
  submit: ->
    $("#" + @search_form).submit()
    $("#" + @resultsId).html "Sending new query..."

  # Scroll the page automatically
  autoScroll: (enabled) ->
    if enabled == true
      return  if @scroll_fnId
      window._currPos = 0
      @scroll_fnId = setInterval(->
        if window._currPos < document.height
          window.scrollTo 0, document.height
          window._currPos = document.height
      , 100)
    else
      return  unless @scroll_fnId
      if @scroll_fnId
        clearInterval @scroll_fnId
        window._currPost = 0
        @scroll_fnId = null

  # Show/hide metadata
  autoMetaData: (enabled) ->
    if enabled == true
      $("table#results td.line div.tags").show()
    else
      $("table#results td.line div.tags").hide()

  # Show/hide times
  autoDateTime: (enabled) ->
    if enabled == true
      $("table#results th.time, table#results td.time").show()
    else
      $("table#results th.time, table#results td.time").hide()

namespace "Matt.Printer", (exports) ->
  message1 = "Yo ho ho"
  message2 = "Five dwarves"

  exports.print1 = ->
    console.log message1

  exports.print2 = ->
    console.log message2