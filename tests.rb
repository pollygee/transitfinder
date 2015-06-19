require 'minitest/autorun'
require 'rack/test'

#ENV["TEST"] = ENV["RACK_ENV"] = "test"

require './db/setup'
require './lib/all'

require './server'

require 'pry'

class TransportTest < Minitest::Test
  include Rack::Test::Methods

  def app
    TransportApp
  end

  def test_getting_closest_train
    get "/closest_train",
      lat: "38.9059620",
      long: "-77.0423670"
    assert_equal 200, last_response.status
    assert_equal "0.09164171896807204", last_response.body
  end
end