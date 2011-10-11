class LogParser

  HEADER_PARSER     = %r{^(\w{3})\s+(\d+) ([\d\:]+) (\w+) (\w+)\[(\d+)\]\: }
  XTRA_MARKER_START = " [XTRA|"
  XTRA_PARSER       = %r{ \[XTRA\|(.*)\|\]$}
  FIELD_MAPPING     = {
    :iid => "instance_id",
    :cid => "customer_id",
    :lid => "loan_id",
    :uid => "user_id",
    :fil => "file",
    :lin => "line",
    :mth => "method",
    :cls => "class",
    :spr => "super",
    :rkt => "rake_task",
    :rku => "rake_task_uid",
    :rkm => "rake_task_time",
    :rtn => "rake_task_name",
    :tyr => "year",
    :tmo => "month",
    :tdy => "day",
    :thr => "hour",
    :tmn => "minute",
    :tsc => "secs",
    :tsu => "usecs",
  }

  def initialize(line)
    @original = line.to_s.dup
    @line     = @original.dup
    @parsed   = false
    @options  = { }
  end

  def parse
    @cleaned_line = ''
    # Headers
    if @line =~ HEADER_PARSER
      @options[:box] = $4
      @options[:app] = $5
      @options[:pid] = $6
      @options[:tyr] = Time.now.year
      @options[:tdy] = $2.to_i
      @options[:tsu] = 0
      @options[:tmo] = %w{ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec }.index($1) + 1
      a, b, c        = $3.split(":").map { |x| x.to_i }
      @options[:thr] = a
      @options[:tmn] = b
      @options[:tsc] = c
      @line          = @line[@line.index(":", 15) + 2 .. -1]
    end
    # Extras
    if @line =~ XTRA_PARSER
      $1.split("|").each { |s| k, *v = s.split(":"); @options[k.to_sym] = v.join(":") }
      @line = @line[0, @line.rindex(XTRA_MARKER_START)]
    end
  end

  def rm_options(*keys)
    default_value = keys.last.is_a?(Symbol) ? nil : keys.pop
    keys.map { |k| @options.delete(k) || default_value }
  end

  def time
    @time ||= "%04i-%02i-%02i %02i:%02i:%02i.%03i" % rm_options(:tyr, :tmo, :tdy, :thr, :tmn, :tsc, :tsu, 0).map { |x| x.to_i }
  end

  def box
    @box ||= rm_options(:box, "missing").first
  end

  def app
    @app ||= rm_options(:app, "missing").first
  end

  def line
    @final_line ||= %{<div class="line">#{ERB::Util.h(@line).gsub(" XSEPX ", '<br/>')}</div>#{labels}#{org}}
  end

  def labels
    _    = rm_options :secs, :app
    @pid = rm_options :pid, "missing"
    tags = [
      tag_for(:box, rm_options(:box)),
      tag_for(:object, rm_options(:spr, :cls, :iid)),
      tag_for(:file, rm_options(:fil, :lin, :mth)),
      tag_for(:rake, rake_labels),
      tag_for(:customer, rm_options(:cid)),
      tag_for(:loan, rm_options(:lid)),
      tag_for(:user, rm_options(:uid)),
    ]
    @options.each { |k, v| tags << tag_for(k, v) }
    tags.compact!
    return "" if tags.empty?
    %{\n<div class="tags">\n  #{tags.join("\n  ")}\n</div>\n}
  end

  def rake_labels
    ary = rm_options(:rkt, :rku, :rkm, :rtn)
    return ary if ary.empty?
    uid = ary[1].split('-').last
    time = ary[2][-4,2] + ":" + ary[2][-2,2]
    name = ary[3]
    [uid, time, name]
  rescue Exception
    ['error', 'error', 'error']
  end

  def tag_for(label, *texts)
    text = Array[texts].flatten.map { |x| x.to_s.strip }.reject { |x| x.empty? }.join(' : ')
    return nil if text.empty?
    label = FIELD_MAPPING[label] if FIELD_MAPPING.key?(label)
    %{<span class="#{label.to_s.gsub("_", "-")}"><span class="icon">&nbsp;</span>#{text}</span>&nbsp;}
  end

  def org
    %{<!-- #{@original} -->}
  end

  def render
    parse unless @parsed
    #<td class="box">#{box}</td>
    #<td class="app">#{app}</td>
    <<-HTML.gsub(/^ {6}/, '')
      <tr>
        <td class="time">#{time}</td>
        <td class="line">#{line}</td>
      </tr>
    HTML
  end

end