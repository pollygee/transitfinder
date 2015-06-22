require 'sinatra/base'
require 'tilt/erubis' # Fixes a warning
require 'rack/cors'
require 'pry'
require './db/setup'
require './lib/all'
require 'haversine'
require 'httparty'

class TransportApp < Sinatra::Base
  before do
    headers["Content-Type"] = "application/json"
  end

  after do
    ActiveRecord::Base.connection.close
  end

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: :get
    end
  end
  
  get "/train" do
    user_long = params["long"].to_f
    user_lat =  params["lat"].to_f
    t = WmataAPI.new 
    list = t.trains_w_distances user_long, user_lat
    final = t.trains_live_data(t.sorted_3 list)
  end

  get "/bus" do
    user_long = params["long"].to_f
    user_lat =  params["lat"].to_f
    b = WmataAPI.new
    closest_3_stations = b.bus_w_distances user_long, user_lat
    t = b.bus_predictions closest_3_stations
  end

  get "/bike" do
    user_long = params["long"].to_f
    user_lat =  params["lat"].to_f
    bi = WmataAPI.new
    closest_3_stations = bi.bike_w_distances user_long, user_lat

    # live_bike_data = HTTParty.get("http://www.capitalbikeshare.com/data/stations/bikeStations.xml", query: { api_key: "#{@token}" })
    # all_stations_with_distance = []
    # all_bike_stations = live_bike_data["stations"]["station"]
    # all_bike_stations.each do |station|
    #   station_long = station["long"].to_f
    #   station_lat = station["lat"].to_f
    #   #how_far is moved to API so this will have to be refactored to make it work
    #   dist_to_station = how_far(user_long, user_lat, station_long, station_lat)
    #   station_with_distance = {station_name: station["name"], 
    #                           bikes_available: station["nbBikes"],
    #                           empty_docks: station["nbEmptyDocks"],
    #                           distance: dist_to_station}
    #   all_stations_with_distance << station_with_distance
    #   binding.pry
    # end
    # sorted_list = all_stations_with_distance.sort_by {|hsh| hsh[:distance]}
    # sorted_list.first(3).to_json
    # binding.pry
  end
end



if $0 == __FILE__
  TransportApp.start!
end