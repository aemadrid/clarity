(function() {
  window.Search = {
    search_form: "search",
    resultsId: "results",
    search_fields: ["term1", "term2", "term3"],
    file_list: "file-list",
    logfiles: {},
    past_params: null,
    url: "/perform",
    scroll_fnId: null,
    init: function(logfiles, params) {
      this.logfiles = logfiles;
      this.past_params = params;
      this.bind_grep_tool();
      this.bind_tail_tool();
      this.bind_options();
      if (!this.past_params) {
        return;
      }
      if (this.past_params["tool"] === "grep") {
        $("#grep-label").trigger("click");
      } else {
        $("#tail-tool").trigger("click");
      }
      $("#" + this.file_list).val(this.past_params["file"]);
      jQuery.each(this.search_fields, function() {
        return $("#" + this).val(Search.past_params[this]);
      });
      if (this.past_params["sh"] || this.past_params["eh"]) {
        this.showAdvanced();
        if (this.past_params["sh"]) {
          jQuery.each(["sh", "sm", "ss"], function() {
            return $("#" + this).val(Search.past_params[this]);
          });
        }
        if (this.past_params["eh"]) {
          return jQuery.each(["eh", "em", "es"], function() {
            return $("#" + this).val(Search.past_params[this]);
          });
        }
      }
    },
    bind_options: function() {
      $("#auto-scroll").bind("change", function() {
        return Search.autoScroll(this.checked);
      });
      $("#auto-scroll").attr("checked", false).trigger("change");
      $("#auto-meta").bind("change", function() {
        return Search.autoMetaData(this.checked);
      });
      $("#auto-meta").attr("checked", true).trigger("change");
      $("#auto-datetime").bind("change", function() {
        return Search.autoDateTime(this.checked);
      });
      return $("#auto-datetime").attr("checked", true).trigger("change");
    },
    bind_grep_tool: function() {
      $("#grep-tool").bind("change", function(e) {
        var newlist;
        newlist = "";
        jQuery.each(Search.logfiles["grep"], function() {
          return newlist += "<option value='" + this + "'>" + this + "</option>\n";
        });
        return $("#" + Search.file_list).html(newlist);
      });
      return $("#grep-label").bind("click", function(e) {
        return $("#grep-tool").attr("checked", "checked").val("grep").trigger("change");
      });
    },
    bind_tail_tool: function() {
      $("#tail-tool").bind("change", function(e) {
        var newlist;
        newlist = "";
        jQuery.each(Search.logfiles["tail"], function() {
          return newlist += "<option value='" + this + "'>" + this + "</option>\n";
        });
        return $("#" + Search.file_list).html(newlist);
      });
      return $("#tail-label").bind("click", function(e) {
        return $("#tail-tool").attr("checked", "checked").val("tail").trigger("change");
      });
    },
    clear: function() {
      return jQuery.each(this.search_fields, function() {
        return $("#" + this).val("");
      });
    },
    showAdvanced: function() {
      $("#enable-advanced").hide();
      $("#disable-advanced").show();
      return $(".advanced-options").show();
    },
    hideAdvanced: function() {
      this.clearAdvanced();
      $("#enable-advanced").show();
      $("#disable-advanced").hide();
      return $(".advanced-options").hide();
    },
    clearAdvanced: function() {
      return $("#advanced-options input").val("");
    },
    submit: function() {
      $("#" + this.search_form).submit();
      return $("#" + this.resultsId).html("Sending new query...");
    },
    autoScroll: function(enabled) {
      if (enabled === true) {
        if (this.scroll_fnId) {
          return;
        }
        window._currPos = 0;
        return this.scroll_fnId = setInterval(function() {
          if (window._currPos < document.height) {
            window.scrollTo(0, document.height);
            return window._currPos = document.height;
          }
        }, 100);
      } else {
        if (!this.scroll_fnId) {
          return;
        }
        if (this.scroll_fnId) {
          clearInterval(this.scroll_fnId);
          window._currPost = 0;
          return this.scroll_fnId = null;
        }
      }
    },
    autoMetaData: function(enabled) {
      if (enabled === true) {
        return $("table#results td.line div.tags").show();
      } else {
        return $("table#results td.line div.tags").hide();
      }
    },
    autoDateTime: function(enabled) {
      if (enabled === true) {
        return $("table#results th.time, table#results td.time").show();
      } else {
        return $("table#results th.time, table#results td.time").hide();
      }
    }
  };
  namespace("Matt.Printer", function(exports) {
    var message1, message2;
    message1 = "Yo ho ho";
    message2 = "Five dwarves";
    exports.print1 = function() {
      return console.log(message1);
    };
    return exports.print2 = function() {
      return console.log(message2);
    };
  });
}).call(this);
