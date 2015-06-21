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

  @token = File.read "./token.txt"
  
  def how_far a_long, a_lat, b_long, b_lat
    dis = Haversine.distance(a_long, a_lat, b_long, b_lat)
    dis.to_miles
  end

  def train_station_info station_code
    @token = File.read "./token.txt"
    @station_info = HTTParty.get("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{station_code}", query: { api_key: "#{@token}" })
  end
  
  get "/train" do
    user_long = params["long"].to_f
    user_lat =  params["lat"].to_f
    all_trains = Train.all
    trains_and_distance = []
    all_trains.each do |train|
      train_info = train.attributes
      distance_to_user = how_far(user_long, user_lat, train.longitude, train.latitude)
      train_info[:distance] = distance_to_user
      trains_and_distance << train_info
    end

    sorted_list = trains_and_distance.sort_by {|hsh| hsh[:distance]}
    close_train_list= sorted_list.first(3)

    full_station_info = sorted_list.first(3)
    close_train_list.each do |station|
      #station_info   = HTTParty.get("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{station_code}", query: { api_key: "#{token}" })      
      station[:next_train] = train_station_info station["code"]
    end
    final = close_train_list.to_json

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

  get "/bus" do
    user_long = params["long"].to_f
    user_lat =  params["lat"].to_f
    #https://api.wmata.com/Bus.svc/json/jBusPositions?long=-76.9&lat=42&1000&api_key=d311c928b8364eff80d7462f7938b2b1
    @token = File.read "./token.txt"
    bus_data = HTTParty.get("https://api.wmata.com/Bus.svc/json/jStops?long=#{user_long}&lat=#{user_lat}&1000&api_key=#{@token}")
    all_bus_stations = bus_data["Stops"]
    all_stations_with_distance = []
    all_bus_stations.each do |station|
      station_long = station["Lon"].to_f
      station_lat = station["Lat"].to_f
      dist_to_station = how_far(user_long, user_lat, station_long, station_lat)
      bus_predictions = HTTParty.get("https://api.wmata.com/NextBusService.svc/json/jPredictions/?StopID=#{station["StopID"]}", query: {api_key: "#{@token}" })
      station_with_distance = { station_name: station["Name"],
                                routes: station["Routes"],
                                stop_id: station["StopID"],
                                predictions: bus_predictions["Predictions"]}
      all_stations_with_distance << station_with_distance
    end
    sorted_list = all_stations_with_distance.sort_by {|hsh| hsh[:distance]}
    t = sorted_list.first(3).to_json
  end


end

if $0 == __FILE__
  TransportApp.start!
end