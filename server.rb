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

  #@token = File.read "./token.txt"
  
  # def how_far a_long, a_lat, b_long, b_lat
  #   dis = Haversine.distance(a_long, a_lat, b_long, b_lat)
  #   dis.to_miles
  # end

  # def train_station_info station_code
  #   @token = File.read "./token.txt"
  #   @station_info = HTTParty.get("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{station_code}", query: { api_key: "#{@token}" })
  # end
  
  get "/train" do
    user_long = params["long"].to_f
    user_lat =  params["lat"].to_f
    t = WmataAPI.new 
    list = t.trains_w_distances user_long, user_lat
    binding.pry
    final = t.trains_live_data(t.sorted_3 list)
    binding.pry
  end

  get "/bike" do
    user_long = params["long"].to_f
    user_lat =  params["lat"].to_f
    #all_bike_stations = Bike.all
    live_bike_data = HTTParty.get("http://www.capitalbikeshare.com/data/stations/bikeStations.xml", query: { api_key: "#{@token}" })
    all_stations_with_distance = []
    all_bike_stations = live_bike_data["stations"]["station"]
    all_bike_stations.each do |station|
      station_long = station["long"].to_f
      station_lat = station["lat"].to_f
      dist_to_station = how_far(user_long, user_lat, station_long, station_lat)
      station_with_distance = {station_name: station["name"], 
                              bikes_available: station["nbBikes"],
                              empty_docks: station["nbEmptyDocks"],
                              distance: dist_to_station}
      all_stations_with_distance << station_with_distance
    end
    sorted_list = all_stations_with_distance.sort_by {|hsh| hsh[:distance]}
    sorted_list.first(3).to_json
    binding.pry
  end



end

if $0 == __FILE__
  TransportApp.start!
end