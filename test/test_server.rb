require 'test_helper'

context "#Toto::Server - Defaults" do
  setup do
    @config = Toto::Config.new({ :prefix => "article_dir"})
    @toto = Rack::MockRequest.new(Toto::Server.new(@config))
  end

  asserts_topic.kind_of Rack::MockRequest
  asserts("correct prefix dir") { @config[:prefix] }.equals "article_dir"

  # TODO: start parsing requests and see what you get back.
  context "can get /" do
    setup { @toto.get("/") }
    asserts("returns a 200")                { topic.status }.equals 200
    asserts("body is not empty")            { not topic.body.empty? }
    asserts("content type is set properly") { topic.content_type }.equals "text/html"
    should("include a couple of articles")   { topic.body }.includes_elements(".article", 3)
    should("include an article summary")    { topic.body }.includes_html("p" => /Once upon a time.*/)
    should("have html from layout.rb")      { topic.body }.includes_html("title" => /tests/)
    should("have html from index.rhtml")      { topic.body }.includes_html("h1" => /index/)
  end

  context "can get /article_dir/the-dichotomy-of-design/" do
    setup { @toto.get("/article_dir/the-dichotomy-of-design/") }
    asserts("returns a 200")                { topic.status }.equals 200
    asserts("body is not empty")            { not topic.body.empty? }
    asserts("content type is set properly") { topic.content_type }.equals "text/html"
    should("include the content")   { topic.body }.includes_html("p" => /Once upon a time/)
    should("have html from layout.rb")      { topic.body }.includes_html("title" => /tests/)
    should("have static from @config[:static_path]")  { topic.body }.includes_html("font" => "http://static.whatever.com/css/main.css")

    should("have html from article.rb")      { topic.body }.includes_html("h2" => /the wizard of oz/)
  end

  context "can get /about/" do
    setup { @toto.get("/about/") }
    asserts("returns a 200")                { topic.status }.equals 200
    asserts("body is not empty")            { not topic.body.empty? }
    asserts("content type is set properly") { topic.content_type }.equals "text/html"
    should("include the content")   { topic.body }.includes_html("h1" => /this is an about page/)
  end

  context "can get /unknown_page/" do
    setup { @toto.get("/unknown_page/") }
    asserts("returns a 404")                { topic.status }.equals 404
    asserts("body is not empty")            { not topic.body.empty? }
    asserts("content type is set properly") { topic.content_type }.equals "text/html"
    should("include the content")   { topic.body }.includes_html("font" => /not in Kansas/)
  end
end
