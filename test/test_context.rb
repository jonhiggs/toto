require 'test_helper'

context "#Toto::Context - Defaults" do
  setup do
    Toto::Paths[:articles] = "test/articles"
    Toto::Paths[:pages] = "test/templates"
    Toto::Paths[:templates] = "test/templates"
    config = Toto::Config.new({})
    context = {}
    path = "/"
    env = "testing"
    Toto::Context.new(context, config)
  end

  asserts_topic.kind_of Toto::Context

  asserts(:title).equals "toto"
  asserts("can render") { topic.render("index", :html) }.equals "something"
end
