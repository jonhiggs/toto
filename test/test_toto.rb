require 'test_helper'
require 'date'

URL = "http://toto.oz"
AUTHOR = "toto"
GITHUB = {
  :user => "testuser",
  :articles_repo => "testrepo",
  :markdown_dir => "/markdown"
}

context Toto do
  setup do
    @config = Toto::Config.new(:markdown => true, :author => AUTHOR, :url => URL, :github => GITHUB)
    @toto = Rack::MockRequest.new(Toto::Server.new(@config))
    Toto::Paths[:articles] = "test/articles"
    Toto::Paths[:pages] = "test/templates"
    Toto::Paths[:templates] = "test/templates"
  end

  context "GET /" do
    setup { @toto.get('/') }

    asserts("returns a 200")                { topic.status }.equals 200
    asserts("body is not empty")            { not topic.body.empty? }
    asserts("content type is set properly") { topic.content_type }.equals "text/html"
    should("include a couple of article")   { topic.body }.includes_elements("#articles li", 3)
    should("include an archive")            { topic.body }.includes_elements("#archives li", 2)
    should("have html from layout.rb")      { topic.body }.includes_html("title" => /tests/)

    context "with no articles" do
      setup { Rack::MockRequest.new(Toto::Server.new(@config.merge(:ext => 'oxo'))).get('/') }

      asserts("body is not empty")          { not topic.body.empty? }
      asserts("returns a 200")              { topic.status }.equals 200
    end

    context "with a user-defined to_html" do
      setup do
        @config[:to_html] = lambda do |path, page, binding|
          ERB.new(File.read("#{path}/#{page}.rhtml")).result(binding)
        end
        @toto.get('/')
      end

      asserts("returns a 200")                { topic.status }.equals 200
      asserts("body is not empty")            { not topic.body.empty? }
      asserts("content type is set properly") { topic.content_type }.equals "text/html"
      should("include a couple of article")   { topic.body }.includes_elements("#articles li", 3)
      should("include an archive")            { topic.body }.includes_elements("#archives li", 2)
      asserts("Etag header present")          { topic.headers.include? "ETag" }
      asserts("Etag header has a value")      { not topic.headers["ETag"].empty? }
    end
  end

  context "GET /about" do
    setup { @toto.get('/about') }
    asserts("returns a 200")                { topic.status }.equals 200
    asserts("body is not empty")            { not topic.body.empty? }
    should("have access to @articles")      { topic.body }.includes_html("#count" => /5/)
  end

  context "GET a single article" do
    setup { @toto.get("/1900/05/17/the-wonderful-wizard-of-oz") }
    asserts("returns a 200")                { topic.status }.equals 200
    asserts("content type is set properly") { topic.content_type }.equals "text/html"
    should("contain the article")           { topic.body }.includes_html("p" => /<em>Once upon a time<\/em>/)
    should("contain the comments")          { topic.body }.includes_elements(".comments", 1)
    should("contain local path")            { topic.body }.includes_elements(".local_path", 1)
    should("contain history url")           { topic.body }.includes_html(".history_url" => /https:\/\/github.com\/testuser\/testrepo\/commits\/master\/markdown\/1900-05-17-the-wonderful-wizard-of-oz.txt/)
  end

  context "GET a single article" do
    setup { @toto.get("/2009/04/01/tilt-factor") }
    asserts("returns a 200")                { topic.status }.equals 200
    should("not contain comments")          { topic.body }.includes_elements(".comments", 0)
  end

  context "GET an unoriginal artical with comments enabled" do
    setup { @toto.get("/2001/01/01/two-thousand-and-one") }
    asserts("returns a 200")            { topic.status }.equals 200
    should("contain comments")          { topic.body }.includes_elements(".comments", 1)
  end

  context "GET an unoriginal artical" do
    setup { @toto.get("/2009/12/04/some-random-article") }
    asserts("returns a 200")                { topic.status }.equals 200
    should("contain comments")          { topic.body }.includes_elements(".comments", 0)
    should("contain source_name")       { topic.body }.includes_html("span" => /source_name_is_google/)
    should("contain source_url")        { topic.body }.includes_html("span" => /http:\/\/www.google.com\//)
  end

  context "GET to an unknown route with a custom error" do
    setup do
      @config[:error] = lambda {|code| "error: #{code}" }
      @toto.get('/unknown')
    end

    should("returns a 404") { topic.status }.equals 404
    should("return the custom error") { topic.body }.equals "error: 404"
  end

  context "Request is invalid" do
    setup { @toto.delete('/invalid') }
    should("returns a 400") { topic.status }.equals 400
  end

  context "GET /index.xml (atom feed)" do
    setup { @toto.get('/index.xml') }
    asserts("content type is set properly") { topic.content_type }.equals "application/xml"
    asserts("body should be valid xml")     { topic.body }.includes_html("feed > entry" => /.+/)
    asserts("summary shouldn't be empty")   { topic.body }.includes_html("summary" => /.{10,}/)
  end
  context "GET /index?param=testparam (get parameter)" do
    setup { @toto.get('/index?param=testparam')   }
    asserts("returns a 200")                { topic.status }.equals 200
    asserts("content type is set properly") { topic.content_type }.equals "text/html"
    asserts("contain the env variable")           { topic.body }.includes_html("p" => /env passed: true/)
    asserts("access the http get parameter")           { topic.body }.includes_html("p" => /request method type: GET/)
    asserts("access the http parameter name value pair")           { topic.body }.includes_html("p" => /request name value pair: param=testparam/)
  end

  context "creating an article" do
    setup do
      @config[:markdown] = true
      @config[:date] = lambda {|t| t.strftime("%Y/%m/%d") }
      @config[:summary] = {:length => 50}
    end

    context "with the bare essentials" do
      setup do
        Toto::Article.new({
          :title => "Toto & The Wizard of Oz.",
          :body => "#Chapter I\nhello, *stranger*."
        }, @config)
      end

      should("have a title")               { topic.title }.equals "Toto & The Wizard of Oz."
      should("parse the body as markdown") { topic.body }.equals "<h1>Chapter I</h1>\n\n<p>hello, <em>stranger</em>.</p>\n"
      should("create an appropriate slug") { topic.slug }.equals "toto-and-the-wizard-of-oz"
      should("set the date")               { topic.date }.equals Date.today.strftime("%Y/%m/%d")
      should("set the modification date")  { topic.modified }.equals Date.today.strftime("%Y/%m/%d")
      should("create a summary")           { topic.summary }.equals "Chapter I\n\nhello, stranger."
      should("have an author")             { topic.author }.equals AUTHOR
      should("have a path")                { topic.path }.equals "/toto-and-the-wizard-of-oz/"
      should("have a url")                 { topic.url }.equals "#{URL}/toto-and-the-wizard-of-oz/"
      should("have empty tag list")        { topic.tags }.equals []
      should("have empty category list")   { topic.categories }.equals []
    end

    context "with an source attributation" do
      setup do
        Toto::Article.new({
          :title => "Toto & The Wizard of Oz.",
          :body => "#Chapter I\nhello, *stranger*.",
          :original => false,
          :source_name => "google",
          :source_url => "http://www.google.com/"
        }, @config)
      end

      should("say it's not original")       { topic.original == false }
      should("say who wrote it")            { topic.source_name}.equals "google"
      should("say where it can be found")   { topic.source_url}.equals "http://www.google.com/"
    end

    context "with a user-defined summary" do
      setup do
        Toto::Article.new({
          :title => "Toto & The Wizard of Oz.",
          :body => "Well,\nhello ~\n, *stranger*."
        }, @config.merge(:markdown => false, :summary => {:max => 150, :delim => /~\n/}))
      end

      should("split the article at the delimiter") { topic.summary }.equals "Well,\nhello"
      should("not have the delimiter in the body") { topic.body !~ /~/ }
    end

    context "with everything specified" do
      setup do
        Toto::Article.new({
          :title  => "The Wizard of Oz",
          :body   => ("a little bit of text." * 5) + "\n" + "filler" * 10,
          :date   => "19/10/1976",
          :modified => "02/03/2022",
          :slug   => "wizard-of-oz",
          :author => "toetoe",
          :categories => 'movies, books, cat with space',
          :tags => 'testing, whatever, tag with space',
          :comments => true,
          :source_name => "i am source",
          :source_url => "http://www.source.com"
        }, @config)
      end

      should("parse the date") { [topic[:date].month, topic[:date].year] }.equals [10, 1976]
      should("parse the modified date") { [topic.modified.month, topic.modified.year] }.equals [3, 2022]
      should("use the slug")   { topic.slug }.equals "wizard-of-oz"
      should("use the author") { topic.author }.equals "toetoe"
      should("contain the categories") { topic.categories }.equals %w[books cat_with_space movies]
      should("contain the tags") { topic.tags }.equals  %w[tag_with_space whatever testing]
      should("contains correct first tag") { topic.tags.first }.equals "tag_with_space"
      should("contain comments") { topic.comments }.equals true
      should("contain source name") { topic.source_name }.equals "i am source"
      should("contain source url") { topic.source_url }.equals "http://www.source.com"
      should("contain local path") { topic.local_path }.equals nil # this should be nil when their is not a local file.
      should("contain history url") { topic.history_url }.equals nil # this should be nil when their is not a local file.

      context "and long first paragraph" do
        should("create a valid summary") { topic.summary }.equals ("a little bit of text." * 5).chop + "&hellip;"
      end

      context "and a short first paragraph" do
        setup do
          @config[:markdown] = false
          Toto::Article.new({:body => "there ain't such thing as a free lunch\n" * 10}, @config)
        end

        should("create a valid summary") { topic.summary.size }.within 75..80
      end
    end

    context "in a subdirectory" do
      context "with implicit leading forward slash" do
        setup do
          conf = Toto::Config.new({})
          conf.set(:prefix, "blog")
          Toto::Article.new({
            :title => "Toto & The Wizard of Oz.",
            :body => "#Chapter I\nhello, *stranger*."
          }, conf)
        end

        should("be in the directory") { topic.path }.equals "/blog/toto-and-the-wizard-of-oz/"
      end

      context "with explicit leading forward slash" do
        setup do
          conf = Toto::Config.new({})
          conf.set(:prefix, "/blog")
          Toto::Article.new({
            :title => "Toto & The Wizard of Oz.",
            :body => "#Chapter I\nhello, *stranger*."
          }, conf)
        end

        should("be in the directory") { topic.path }.equals "/blog/toto-and-the-wizard-of-oz/"
      end

      context "with explicit trailing forward slash" do
        setup do
          conf = Toto::Config.new({})
          conf.set(:prefix, "blog/")
          Toto::Article.new({
            :title => "Toto & The Wizard of Oz.",
            :body => "#Chapter I\nhello, *stranger*."
          }, conf)
        end

        should("be in the directory") { topic.path }.equals "/blog/toto-and-the-wizard-of-oz/"
      end
    end
  end

  context "using Config#set with a hash" do
    setup do
      conf = Toto::Config.new({})
      conf.set(:summary, {:delim => /%/})
      conf
    end

    should("set summary[:delim] to /%/") { topic[:summary][:delim].source }.equals "%"
    should("leave the :max intact") { topic[:summary][:max] }.equals 150
  end

  context "using Config#set with a block" do
    setup do
      conf = Toto::Config.new({})
      conf.set(:to_html) {|path, p, _| path + p }
      conf
    end

    should("set the value to a proc") { topic[:to_html] }.respond_to :call
  end

  context "testing individual configuration parameters" do
    context "generate error pages" do
      setup do
        conf = Toto::Config.new({})
        conf.set(:error) {|code| "error code #{code}" }
        conf
      end

      should("create an error page") { topic[:error].call(400) }.equals "error code 400"
    end
  end

  context "extensions to the core Ruby library" do
    should("respond to iso8601") { Date.today }.respond_to?(:iso8601)
  end
end


