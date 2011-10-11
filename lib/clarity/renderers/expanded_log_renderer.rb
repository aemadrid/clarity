require 'uri'
require 'erb'

class ExpandedLogRenderer

  def render(line = { })
    LogParser.new(line).render
  end

  def starting_data
    #<th>Box</th>
    #<th>App</th>
    <<-HTML.gsub(/^ {6}/, '')
            <table id='results'>
              <thead>
                <tr>
                  <th class="time">Time</th>
                  <th class="line">Line</th>
                </tr>
              </thead>
              <tbody>
    HTML
  end

  def finalize(line_count, start_time)
    if line_count && line_count > 0
      time_unit = "second/s"
      time = Time.now - start_time rescue 0.0
      if time > 60.0
        time = time / 60
        time_unit = "minute/s"
      end
      <<-HTML.gsub(/^ {8}/, '')
                </tbody>
              </table>
              <div class="alert-message success">
                <p><strong>Done!</strong> You successfully loaded #{line_count || 0} lines in #{'%.2f' % time} #{time_unit}.</p>
              </div>
            </div>
          </div>
      </body>
      </html>
      HTML
    else
      <<-HTML.gsub(/^ {8}/, '')
                </tbody>
              </table>
              <div class="alert-message info">
                <p><strong>Sorry!</strong> There were no lines found to display for your query.</p>
              </div>
            </div>
          </div>
      </body>
      </html>
      HTML
    end
  end

end