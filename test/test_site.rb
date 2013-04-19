require 'test_helper'

context "#Toto::Site - Defaults" do
  setup do
    config = Toto::Config.new({})
    Toto::Site.new(config)
  end

  asserts_topic.kind_of Toto::Site
  asserts("url from Config") {topic[:url]}.equals "http://127.0.0.1"
  asserts(:index).includes :articles
end

context "#Toto::Site - /article_directory/the-dichotomy-of-design" do
  setup do
    Toto::Paths[:articles] = "test/articles"
    Toto::Paths[:pages] = "test/templates"
    Toto::Paths[:templates] = "test/templates"
    config = Toto::Config.new({})
    Toto::Site.new(config)
  end

  asserts_topic.kind_of Toto::Site
  asserts("ext from Config") {topic[:ext]}.equals "txt"
  asserts(:index).includes :articles
  asserts(:articles).size 5
  asserts("count articles") { topic.index[:articles].size }.equals 5
  asserts("article from path") { topic.article(%w[article_directory the-dichotomy-of-design])[:title] }.equals "the wizard of oz"
end
