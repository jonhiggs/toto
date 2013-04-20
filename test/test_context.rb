require 'test_helper'

context "#Toto::Context - Defaults" do
  setup do
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
