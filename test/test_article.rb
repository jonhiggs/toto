require 'test_helper'

context "#Toto::Article - 2009-12-11-the-dichotomy-of-design.txt" do
  setup do
    config = Toto::Config.new({})
    route = "test/articles/2009-12-11-the-dichotomy-of-design.txt"
    article = Toto::Article.new(route, config)
  end

  asserts_topic.kind_of Toto::Article
  asserts(:local_path).equals "test/articles/2009-12-11-the-dichotomy-of-design.txt"
  asserts(:slug).equals "the-wizard-of-oz"
  asserts(:summary).equals "Once upon a time&hellip;"
  asserts(:url).equals "http://127.0.0.1/1932/10/12/the-wizard-of-oz/"
  asserts(:body).equals "<p>Once upon a time&hellip;</p>\n"
  asserts(:path).equals "/1932/10/12/the-wizard-of-oz/"
  asserts(:history_url).equals "https://github.com/commits/master/markdown/2009-12-11-the-dichotomy-of-design.txt"
  asserts(:original).equals true
  asserts(:tags).equals []
  asserts(:categories).equals []
  asserts(:comments).nil
  asserts(:modified).equals "12/10/1932"
  asserts(:source_url).nil
  asserts(:source_name).nil
  asserts(:title).equals "the wizard of oz"
  asserts(:date).equals "12/10/1932"
  asserts(:author).equals ENV["USER"]
end

