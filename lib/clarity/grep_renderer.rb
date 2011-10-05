module Clarity
  module GrepRenderer
    attr_accessor :response
    attr_writer :renderer

    def renderer
      @renderer ||= ExpandedLogRenderer.new
    end

    # once download is complete, send it to client
    def receive_data(data)
      unless instance_variable_defined? :@buffer
        @buffer = StringScanner.new("")
        response.chunk renderer.starting_data
      end

      @buffer << data

      while line = @buffer.scan_until(/\n/)
        response.chunk renderer.render(line)
        flush
      end      
    end
            
    def flush
      response.send_chunks
    end
    
    def close
      ProcessTree.kill(get_status.pid)      
    end    

    def unbind          
      response.chunk renderer.finalize
      response.chunk ''
      close
      flush
      puts 'Done'
    end
  end
end
