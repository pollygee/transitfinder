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
    t = last_response
    assert_equal 200, last_response.status
    assert last_response.body.include?('Dupont Circle')
    assert last_response.body.include?('Farragut West')
    assert last_response.body.include?('Farragut North')
    response = JSON.parse last_response.body
    assert_equal 3, response.count
    assert response.first['name']
    assert response.first['address']
    assert response.first['code']
    assert response.first['latitude']
    assert response.first['longitude']
  end

  def test_train_different_location_returns_different_response
    get "/train",
      lat: "37.9059620",
      long: "-78.0423670"
    assert_equal 200, last_response.status
    assert last_response.body.include?('Wiehle-Reston East')
    assert last_response.body.include?('Vienna"')
    assert last_response.body.include?('Spring Hill')
    response = JSON.parse last_response.body
    assert_equal 3, response.count
  end

  def test_bike_info
    get "/bike",
      lat: "38.9059620",
      long: "-77.0423670"
    assert_equal 200, last_response.status
    response = JSON.parse last_response.body
    assert_equal response[0]['name'], '18th & M St NW'
    assert_equal response[1]['name'], '19th & K St NW'
    assert_equal response[2]['name'], '19th St & Pennsylvania Ave NW'
    refute_operator response[0]["nbBikes"].to_i, :<, 0
    refute_operator response[1]["nbBikes"].to_i, :<, 0
    refute_operator response[2]["nbBikes"].to_i, :<, 0
  end
  def test_bike_info_different_for_different_locations
    get "/bike",
      lat: "38.926570",
      long: "-77.032419"
    assert_equal 200, last_response.status
    response = JSON.parse last_response.body
    assert_equal response[0]['name'], '14th & Harvard St NW'
    assert_equal response[1]['name'], '14th & V St NW'
    assert_equal response[2]['name'], '16th & Harvard St NW'
  end

  def test_bus_info
    get "/bus",
      lat: "38.9059620",
      long: "-77.0423670"
    assert_equal 200, last_response.status
    assert last_response.body.include?('INDIAN HEAD HWY + WOODLAND DR')
    assert last_response.body.include?('INDIAN HEAD HWY + STONY POINT PL')
    assert last_response.body.include?('INDIAN HEAD HWY + N 1ST ST')
    response = JSON.parse last_response.body
    assert_equal 3, response.count
    assert response.first['Name']
    assert response.first['Routes']
    assert response.first['StopID']
    assert response.first['Lat']
    assert response.first['Lon']
  end
end