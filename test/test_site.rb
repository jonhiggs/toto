require 'test_helper'

context "#Toto::Site - Defaults" do
  setup do
    config = Toto::Config.new({})
    Toto::Site.new(config)
  end

  asserts_topic.kind_of Toto::Site
  asserts("url from Config") {topic[:url]}.equals "http://127.0.0.1"
  asserts(:index).includes :articles
  asserts(:index).includes :archives
end

context "#Toto::Site - /" do
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
  asserts(:index).includes :archives
  asserts("count articles") { topic.index[:articles] }.equals "not sure yet"
  asserts("count archives") { topic.index[:archives] }.equals "not sure yet"
  asserts("article from path") { topic.article "/" }.equals "not sure yet"
end
