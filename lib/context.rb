require 'template'

module Toto
  class Context
    include Template
    attr_reader :env
                                                                                                   
    def initialize ctx = {}, config = {}, path = "/", env = {}
      @config, @context, @path, @env = config, ctx, path, env

      @articles = Site.new(@config).articles.reverse.map do |a|
        Article.new(a, @config)
      end

      ctx.each do |k, v|
        meta_def(k) { ctx.instance_of?(Hash) ? v : ctx.send(k) }
      end
    end
                                                                                                   
    def title
      @config[:title]
    end
                                                                                                   
    def render page, type
      content = to_html page, @config
      if type == :html 
        doc = to_html(:layout, @config, &Proc.new { content }) 
        doc.gsub!(/##STATIC##/, @config[:static_path].sample)
      else
        send(:"to_#{type}", page)
      end
    end
                                                                                                   
    def to_xml page
      xml = Builder::XmlMarkup.new(:indent => 2)
      instance_eval File.read("#{Paths[:templates]}/#{page}.builder")
    end
    alias :to_atom to_xml
                                                                                                   
    def method_missing m, *args, &blk
      @context.respond_to?(m) ? @context.send(m, *args, &blk) : super
    end
  end
end
