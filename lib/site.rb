module Toto
  class Site
    def initialize config
      @config = config
    end

    def [] *args
      @config[*args]
    end

    def []= key, value
      @config.set key, value
    end

    def articles
      Dir["#{Paths[:articles]}/*.#{@config[:ext]}"].sort_by {|entry| File.basename(entry) }
    end

    def pages
      Dir["#{Paths[:templates]}/*.rhtml"].sort_by {|entry| File.basename(entry) }
    end

    def index type = :html
      articles = type == :html ? self.articles.reverse : self.articles
      {:articles => articles.map do |article|
        Article.new article, @config
        # TODO: during tests, this returns {}
      end}.merge archives
    end

    def archives filter = ""
      entries = ! self.articles.empty??
        self.articles.select do |a|
          filter !~ /^\d{4}/ || File.basename(a) =~ /^#{filter}/
        end.reverse.map do |article|
          Article.new article, @config
        end : []

      return :archives => Archives.new(entries, @config)
    end

    def article route
      # NOTE: route is a Toto::Article object
      Article.new("#{Paths[:articles]}/#{route.last}.#{self[:ext]}", @config).load
    end

    def /
      self[:root]
    end

    def go route, env = {}, type = :html
      route << self./ if route.empty?
      type, path = type =~ /html|xml|json/ ? type.to_sym : :html, route.join('/')
      context = lambda do |data, page|
        Context.new(data, @config, path, env).render(page, type)
      end

      body, status = if Context.new.respond_to?(:"to_#{type}")
        if route.first == @config[:prefix]
          context[article(route), :article]
        elsif respond_to?(path)
          context[send(path, type), path.to_sym]
        else
          context[{}, path.to_sym]
          #http 400
        end
      end

    rescue Errno::ENOENT => e
      return :body => http(404).first, :type => :html, :status => 404
    else
      return :body => body || "", :type => type, :status => status || 200
    end

    protected
    def http code
      [@config[:error].call(code), code]
    end

  end
end
