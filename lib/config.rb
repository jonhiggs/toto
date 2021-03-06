module Toto
  class Config < Hash
    Defaults = {
      :author => ENV['USER'],                               # blog author
      :title => Dir.pwd.split('/').last,                    # site title
      :root => "index",                                     # site index
      :url => "http://127.0.0.1",                           # root URL of the site
      :static_path => [ "http://static.whatever.com" ],     # will take a random sample from array.
      :prefix => "article_directory",                       # common path prefix for the blog
      :date => lambda {|now| now.strftime("%d/%m/%Y") },    # date function
      :markdown => :smart,                                  # use markdown
      :disqus => "blah",                                    # disqus name
      :summary => {:max => 150, :delim => /~\n/},           # length of summary and delimiter
      :ext => 'txt',                                        # extension for articles
      :cache => 28800,                                      # cache duration (seconds)
      :github => {:user => "gituser", :articles_repo => "gitrepo", :markdown_dir => 'markdown/'}, # Github username and list of repos
      :meta => {
        :description => "the description of the site.",
        :keywords => %w[ some key words go into here ]
      },
      :to_html => lambda {|path, page, ctx|                 # returns an html, from a path & context
        ERB.new(File.read("#{path}/#{page}.rhtml")).result(ctx)
      },
      :error => lambda {|code|                              # The HTML for your error page
        "<font style='font-size:300%'>toto, we're not in Kansas anymore (#{code})</font>"
      }
    }
    def initialize obj
      self.update Defaults
      self.update obj
    end

    def set key, val = nil, &blk
      if val.is_a? Hash
        self[key].update val
      else
        self[key] = block_given?? blk : val
      end
    end
  end
end
