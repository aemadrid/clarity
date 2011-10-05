# Oct  3 23:47:42 wb01 plt[1467]:

require 'uri'
require 'erb'

class ExpandedLogRenderer

  # Thank you to http://daringfireball.net/2009/11/liberal_regex_for_matching_urls
  #
  URL_PARSER        = %r{\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))}
  HEADER_PARSER     = %r{^(\w{3})\s+(\d+) ([\d\:]+) (\w+) (\w+)\[(\d+)\]\: }
  XTRA_MARKER_START = " [XTRA|"
  XTRA_PARSER       = %r{ \[XTRA\|(.*)\|\]$}
  FIELD_MAPPING     = {
    "iid" => "instance_id",
    "cid" => "customer_id",
    "lid" => "loan_id",
    "uid" => "user_id",
    "fil" => "file",
    "lin" => "line",
    "mth" => "method",
    "cls" => "class",
    "spr" => "super",
    "rkt" => "rake_task",
    "rku" => "rake_task_uid",
    "rkm" => "rake_task_time",
    "rtn" => "rake_task_name",
    "tyr" => "year",
    "tmo" => "month",
    "tdy" => "day",
    "thr" => "hour",
    "tmn" => "minute",
    "tsc" => "secs",
    "tsu" => "usecs",
  }

  def render(line = { })
    # Capture header
    line, headers = capture_headers line

    # Capture/parse extra options
    line, extras  = capture_extras line

    # Return with formatting
    <<-HTML.gsub(/^ {6}/, '')
      <tr>
        <td class="time">#{parse_time(headers, extras)}</td>
        <td class="box">#{parse_box(headers, extras)}</td>
        <td class="app">#{parse_app(headers, extras)}</td>
        <td class="line">#{parse_final_line(line, extras)}</td>
      </tr>
    HTML
  end

  def starting_data
    <<-HTML.gsub(/^ {6}/, '')
            <table class='zebra-striped' id='results'>
              <thead>
                <tr>
                  <th>Time</th>
                  <th>Box</th>
                  <th>App</th>
                  <th>Line</th>
                </tr>
              </thead>
              <tbody>
    HTML
  end

  def finalize
    <<-HTML.gsub(/^ {6}/, '')
              </tbody>
            </table>
            <p id="done">Done</p>
          </div>
        </div>
    </body>
    </html>
    HTML
  end

  private

  def capture_headers(line)
    if line =~ HEADER_PARSER
      headers       = { :box => $4, :app => $5, :pid => $6, :tyr => Time.now.year, :tdy => $2.to_i, :tsu => 0 }
      headers[:tmo] = %w{ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec }.index($1) + 1
      a, b, c       = $3.split(":").map { |x| x.to_i }
      headers[:thr] = a
      headers[:tmn] =b
      headers[:tsc] = c
      line          = line[line.index(":", 15) + 2 .. -1]
    else
      headers = { }
    end
    [line, headers]
  end

  def capture_extras(line)
    if line =~ XTRA_PARSER
      extras = $1.split("|").inject({ }) { |h, s| k, v = s.split(":"); h[k] = v; h }
      line   = line[0, line.rindex(XTRA_MARKER_START)]
    else
      extras = { }
    end
    [line, extras]
  end

  def parse_tags(extras)
    return "" if extras.empty?

    #{
    #  "spr" => "super",
    #  "cls" => "class",
    #  "iid" => "instance_id",
    #
    #  "fil" => "file",
    #  "lin" => "line",
    #  "mth" => "method",
    #
    #  "cid" => "customer_id",
    #  "lid" => "loan_id",
    #  "uid" => "user_id",
    #
    #  "rkt" => "rake_task",
    #  "rku" => "rake_task_uid",
    #  "rkm" => "rake_task_time",
    #  "rtn" => "rake_task_name",
    #}
    #fields     = %w{ spr cls iid }
    #ord_extras = []
    #ord_extras << ["spr", extras.delete]

    html = %{<div class="tags">}
    extras.sort { |a, b| a.first <=> b.first }.each do |k, v|
      tag = tag_for(k, v)
      html << tag if tag
    end
    html << %{</div>}
  end

  def tag_for(label, text)
    text = text.to_s.strip
    return false if text.empty?
    label = label.to_s
    label = FIELD_MAPPING[label] if FIELD_MAPPING.key?(label)
     %{<span class="label #{label.gsub("_", "-")}">#{text}</span>&nbsp;}
  end

  def parse_time(headers, extras)
    "%04i-%02i-%02i %02i:%02i:%02i" % [
      (extras.delete("tyr") || headers[:tyr]).to_i,
      (extras.delete("tmo") || headers[:tmo]).to_i,
      (extras.delete("tdy") || headers[:tdy]).to_i,
      (extras.delete("thr") || headers[:thr]).to_i,
      (extras.delete("tmn") || headers[:tmn]).to_i,
      (extras.delete("tsc") || headers[:tsc]).to_i,
    ]
  end

  def parse_box(headers, extras)
    extras.delete("box") || headers[:box]
  end

  def parse_app(headers, extras)
    extras.delete("app") || headers[:app]
  end

  def parse_final_line(line, extras)
    %{<div class="line">#{ERB::Util.h(line).gsub(" XSEPX ", '<br/>')}</div>\n#{parse_tags(extras)}}
  end

  def html_link(url)
    uri = URI.parse(url) rescue url
    "<a href='#{uri}'>#{url}</a>"
  end

end