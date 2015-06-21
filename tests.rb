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

  def test_train_getting_closest_3_stations
    
    get "/train",
      lat: "38.9059620",
      long: "-77.0423670"
    assert_equal 200, last_response.status
    assert last_response.body.include?('Dupont Circle')
    assert last_response.body.include?('Farragut West')
    assert last_response.body.include?('Farragut North')
    response = JSON.parse last_response.body
    assert_equal 3, response.count
  end

  def test_train_different_location_returns_different_response
    skip
    get "/train",
      lat: "38.9059620",
      long: "-77.0423670"
    assert_equal 200, last_response.status
    assert last_response.body.include?('Dupont Circle')
    assert last_response.body.include?('Farragut West')
    assert last_response.body.include?('Farragut North')
    response = JSON.parse last_response.body
    assert_equal 3, response.count
  end

  def test_bike_info
    skip
    get "/bike",
      lat: "38.9059620",
      long: "-77.0423670"
    assert_equal 200, last_response.status
    assert last_response.body.include?('18th & M St NW')
    assert last_response.body.include?("19th & K St NW")
    assert last_response.body.include?("19th St & Pennsylvania Ave NW")
  end

  def test_bus_info
    skip
    get "/bus",
      lat: "38.9059620",
      long: "-77.0423670"
    assert_equal 200, last_response.status
    assert last_response.body.include?()
  end
end