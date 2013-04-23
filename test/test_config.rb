require 'test_helper'

context "#Toto::Config - Defaults" do
  setup { Toto::Config.new({}) }
  asserts_topic.kind_of Hash 
  asserts("author is") {topic[:author]}.kind_of String
  asserts("title is") {topic[:title]}.kind_of String
  asserts("root is") {topic[:root]}.kind_of String
  asserts("url is") {topic[:url]}.kind_of String
  asserts("static_path is") {topic[:static_path]}.kind_of Array
  asserts("prefix is") {topic[:prefix]}.kind_of String
  asserts("date is") {topic[:date]}.kind_of Proc
  asserts("markdown is") {topic[:markdown]}.kind_of Symbol
  asserts("disqus is") {topic[:disqus]}.kind_of String
  asserts("summary is") {topic[:summary]}.kind_of Hash
  asserts("ext is") {topic[:ext]}.kind_of String
  asserts("cache is") {topic[:cache]}.kind_of Fixnum
  asserts("github is") {topic[:github]}.kind_of Hash
  asserts("to_html is") {topic[:to_html]}.kind_of Proc
  asserts("error") {topic[:error]}.kind_of Proc
  asserts("meta description is") {topic[:meta][:description]}.kind_of String
  asserts("meta keywords is") {topic[:meta][:keywords]}.kind_of Array
end

context "#Toto::Config - Fully Custom" do
  setup do
    Toto::Config.new(
      {
        :author => "a person",
        :title => "a title",
        :root => "/a/path",
        :url => "http://url.com",
        :static_path => [ "1.assets.com", "2.assets.com" ],
        :prefix => "/a/prefix/path",
        :date => Time.new,
        :markdown => :something,
        :disqus => "a_disqus_user",
        :summary => {:max => 200, :delim => /%\n/},
        :ext => 'md',
        :cache => 1234,
        :github => {:user => "ghuser", :articles_repo => "notsure", :markdown_dir => 'md/'},
        :to_html => lambda {|x| x},
        :error => lambda {|y| y},
      }
    )
  end

  asserts("sets author to") {topic[:author]}.equals "a person"
  asserts("sets title to") {topic[:title]}.equals "a title"
  asserts("sets root to") {topic[:root]}.equals "/a/path"
  asserts("sets url to") {topic[:url]}.equals "http://url.com"
  #asserts("sets static_path to") {topic[:static_path]}.equals "1.assets.com", "2.assets.com" ]
  asserts("sets prefix to") {topic[:prefix]}.equals "/a/prefix/path"
  asserts("sets date to") {topic[:date]}.responds_to "year"
  asserts("sets markdown to") {topic[:markdown]}.equals :something
  asserts("sets disqus to") {topic[:disqus]}.equals "a_disqus_user"
  asserts("sets summary max to") {topic[:summary][:max]}.equals 200
  asserts("sets summary delim to") {topic[:summary][:delim]}.equals /%\n/
  asserts("sets ext to") {topic[:ext]}.equals 'md'
  asserts("sets cache to") {topic[:cache]}.equals 1234
  asserts("sets github user to") {topic[:github][:user]}.equals "ghuser"
  asserts("sets github articles_repo to") {topic[:github][:articles_repo]}.equals "notsure"
  asserts("sets github markdown_dir to") {topic[:github][:markdown_dir]}.equals 'md/'
end
