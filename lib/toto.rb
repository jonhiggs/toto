require 'builder'
require 'date'
require 'digest'
require 'erb'
require 'open-uri'
require 'rack'
require 'yaml'

if RUBY_PLATFORM =~ /win32/
  require 'maruku'
  Markdown = Maruku
else
  require 'rdiscount'
end

$:.unshift File.dirname(__FILE__)

require 'ext/ext'

module Toto
  require 'archives'
  require 'article'
  require 'config'
  require 'context'
  require 'server'
  require 'site'

  def self.env
    ENV['RACK_ENV'] || 'production'
  end

  def self.env= env
    ENV['RACK_ENV'] = env
  end
end
