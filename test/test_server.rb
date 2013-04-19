require 'test_helper'

context "#Toto::Server - Defaults" do
  setup do
    @config = Toto::Config.new({ :prefix => "article_dir"})
    Toto::Paths[:articles] = "test/articles"
    Toto::Paths[:pages] = "test/templates"
    Toto::Paths[:templates] = "test/templates"
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
    should("include a couple of articles")   { topic.body }.includes_elements(".entry", 5)
    should("have html from layout.rb")      { topic.body }.includes_html("title" => /tests/)
  end

  context "can get /article_dir/the-dichotomy-of-design" do
    setup { @toto.get("/article_dir/the-dichotomy-of-design") }
    asserts("returns a 200")                { topic.status }.equals 200
    asserts("body is not empty")            { not topic.body.empty? }
    asserts("content type is set properly") { topic.content_type }.equals "text/html"
    should("include the content")   { topic.body }.includes_html("p" => /Once upon a time/)
    should("have html from layout.rb")      { topic.body }.includes_html("title" => /tests/)
  end
end
