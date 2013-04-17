require 'test_helper'

context "#Toto::Server - Defaults" do
  setup do
    config = Toto::Config.new({})
    Toto::Paths[:articles] = "test/articles"
    Toto::Paths[:pages] = "test/templates"
    Toto::Paths[:templates] = "test/templates"
    Rack::MockRequest.new(Toto::Server.new(config))
  end

  asserts_topic.kind_of Rack::MockRequest

  # TODO: start parsing requests and see what you get back.
end
