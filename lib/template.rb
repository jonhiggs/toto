module Toto
  module Template
    def to_html page, config, &blk
      path = ([:layout, :repo].include?(page) ? Paths[:templates] : Paths[:pages])
      subsituted_page = page.to_s.strip.gsub(/##STATIC##/, @config[:static_path].first)
      config[:to_html].call(path, page, binding)
    end

    def markdown text
      if (options = @config[:markdown])
        substituted_text = text.to_s.strip.gsub(/##STATIC##/, @config[:static_path].first)
        Markdown.new(substituted_text, *(options.eql?(true) ? [] : options)).to_html
      else
        text.strip
      end
    end

    def method_missing m, *args, &blk
      self.keys.include?(m) ? self[m] : super
    end

    def self.included obj
      obj.class_eval do
        define_method(obj.to_s.split('::').last.downcase) { self }
      end
    end
  end
end
