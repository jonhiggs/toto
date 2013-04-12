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
  require 'server'
  require 'site'
  require 'config'
  require 'repo'
  require 'archives'
  require 'article'
  require 'context'

  Paths = {
    :templates => "templates",
    :pages => "templates/pages",
    :articles => "articles"
  }

  def self.env
    ENV['RACK_ENV'] || 'production'
  end

  def self.env= env
    ENV['RACK_ENV'] = env
  end
end
