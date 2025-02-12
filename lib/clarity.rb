$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  require File.join(File.dirname(__FILE__), *%w[.. vendor gems environment])
rescue LoadError
end

require 'eventmachine'
require 'evma_httpserver'
require 'json'
require 'yaml'
require 'base64'
require 'clarity/server'
require 'clarity/commands/grep_command_builder'
require 'clarity/commands/tail_command_builder'
require 'clarity/parsers/log_parser'
require 'clarity/renderers/log_renderer'
require 'clarity/renderers/expanded_log_renderer'

module Clarity
  VERSION = '0.9.8'
  ROOT = File.expand_path "..", File.dirname(__FILE__)

  Templates = File.dirname(__FILE__) + '/../views'
  Public    = File.dirname(__FILE__) + '/../public'
end
