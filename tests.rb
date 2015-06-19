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

  def test_getting_closest_3_stations
    get "/closest_train",
      lat: "38.9059620",
      long: "-77.0423670"
    assert_equal 200, last_response.status
    assert last_response.body.include?('Dupont Circle')
    assert last_response.body.include?('Farragut West')
    assert last_response.body.include?('Farragut North')
  end

  def test_getiting_train_station_info
    get "/train_info/A03"

    assert_eqaual 200, last_response.status
    assert last_response.body.include?('Dupont Circle')
    assert last_response.body.include?('Shady Grove')
  end
end