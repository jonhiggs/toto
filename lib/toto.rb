require 'yaml'
require 'date'
require 'erb'
require 'rack'
require 'digest'
require 'open-uri'

if RUBY_PLATFORM =~ /win32/
  require 'maruku'
  Markdown = Maruku
else
  require 'rdiscount'
end

require 'builder'

$:.unshift File.dirname(__FILE__)

require 'ext/ext'

module Toto
  require 'archives'
  require 'article'
  require 'config'
  require 'context'
  require 'repo'
  require 'server'
  require 'site'

  def self.env
    ENV['RACK_ENV'] || 'production'
  end

  def self.env= env
    ENV['RACK_ENV'] = env
  end
end
