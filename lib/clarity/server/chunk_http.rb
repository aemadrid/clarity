require 'erb'

module Clarity

  module ChunkHttp

    LeadIn = ' ' * 1024

    def respond_with_chunks
      response                         = EventMachine::DelegatedHttpResponse.new(self)
      response.status                  = 200
      response.headers['Content-Type'] = 'text/html'
      response.chunk LeadIn
      response
    end

    def respond_with(status, content, options = { })
      response                          = EventMachine::DelegatedHttpResponse.new(self)
      response.headers['Content-Type']  = options.fetch(:content_type, 'text/html')
      response.headers['Cache-Control'] = 'private, max-age=0'
      headers                           = options.fetch(:headers, { })
      headers.each_pair { |h, v| response.headers[h] = v }
      response.status  = status
      response.content = content
      response.send_response
    end

    def render(view)
      @toolbar            = template("_toolbar2.html.erb")
      @content_for_header = template("_header.html.erb")
      template(view)
    end

    def template(filename)
      content = File.read(File.join(Clarity::Templates, filename))
      ERB.new(content).result(binding)
    end

    def public_file(filename)
      File.read(File.join(Clarity::Public, filename))
    rescue Errno::ENOENT
      raise NotFoundError
    end

    def logfiles
      log_files.map { |f| Dir[f] }.flatten.compact.uniq.select { |f| File.file?(f) }.sort
    end

    def scaled_logfiles
      hsh = { }
      logfiles.each do |path|
        app, log = path.split("/")[-2..-1]
        date     = log.gsub(".production.log", "")
        hsh[app] ||= []
        hsh[app] << [date, path]
      end
      hsh.keys.sort.map { |app| [app, hsh[app]] }
    end

    def params
      ENV['QUERY_STRING'].split('&').inject({ }) { |p, s| k, v = s.split('='); p[k.to_s] = CGI.unescape(v.to_s); p }
    end

    def path
      ENV["PATH_INFO"]
    end

  end

end