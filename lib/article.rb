require 'template'

module Toto
  class Article < Hash
    include Template

    def initialize obj, config = {}
      @obj, @config = obj, config
      self.load if obj.is_a? Hash
    end

    def load
      # @obj is path to article file.
      data = if @obj.is_a? String
        local_path = @obj
        meta, body = File.read(@obj).split(/\n\n/, 2)
        self[:body] = body

        YAML.load(meta)
      elsif @obj.is_a? Hash
        @obj
      end.inject({}) {|h, (k,v)| h.merge(k.to_sym => v) }

      self.taint
      self.update data
      self[:date] = Date.parse(self[:date].gsub('/', '-')) rescue Date.today
      self[:local_path] = local_path rescue nil
      self
    end

    def [] key
      self.load unless self.tainted?
      super
    end

    def local_path
      self[:local_path]
    end

    def slug
      self[:slug] || self[:title].slugize
    end

    def summary length = nil
      config = @config[:summary]
      sum = if self[:body] =~ config[:delim]
        self[:body].split(config[:delim]).first
      else
        self[:body].match(/(.{1,#{length || config[:length] || config[:max]}}.*?)(\n|\Z)/m).to_s
      end
      content = markdown(sum.length == self[:body].length ? sum : sum.strip.sub(/\.\Z/, '&hellip;'))
      content.gsub(/<[^>]+>/, "").strip
    end

    def url
      "http://#{(@config[:url].sub("http://", '') + self.path).squeeze('/')}"
    end
    alias :permalink url

    def body
      body = self[:body].gsub("##STATIC##", @config[:static_path].sample)
      markdown body.sub(@config[:summary][:delim], '') rescue markdown body
    end

    def path
      "/#{@config[:prefix]}/#{slug}/".squeeze('/')
    end

    def history_url
      return nil if self.local_path.nil?
      file = File.split(self.local_path).last
      user = @config[:github][:user]
      repo = @config[:github][:articles_repo]
      markdown = @config[:github][:markdown_dir]
      path = File.join("https://github.com/", user, repo, "commits/master", markdown, file)
      URI::encode(path)
    end

    def original
      !self[:source_name] || !self[:source_url]
    end

    def tags
      return [] if self[:tags].nil?
      self[:tags].split(",").sort.map! do |tag|
        tag.strip.gsub(/\s/, "_")
      end
    end

    def categories
      return [] if self[:categories].nil?
      self[:categories].split(",").sort.map! do |tag|
        tag.strip.gsub(/\s/, "_")
      end
    end

    def comments
      @config[:disqus] && self[:comments]
    end

    def modified
      return self.date if self[:modified].nil?
      Date.parse(self[:modified])
    end

    def source_url()  self[:source_url]                      end
    def source_name() self[:source_name]                     end
    def title()       self[:title] || "an article"           end
    def date()        @config[:date].call(self[:date])       end
    def author()      self[:author] || @config[:author]      end

    def to_html() self.load; super(:article, @config)        end
    alias :to_s to_html
  end
end
