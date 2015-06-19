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

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: :get
    end
  end
  def how_far a_long, a_lat, b_long, b_lat
    dis = Haversine.distance(a_long, a_lat, b_long, b_lat)
    dis.to_miles
  end

  def train_station_info station_code
    token = File.read "./token"
    HTTParty.get("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{token}", query: { api_key: "d311c928b8364eff80d7462f7938b2b1" })
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
    close_train_list.each do |upcoming_trains|
      station_info   = HTTParty.get("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{upcoming_trains["code"]}", query: { api_key: "d311c928b8364eff80d7462f7938b2b1" })      
      upcoming_trains[:next_train] = station_info
    end
    final = close_train_list.to_json
  end

  get "/bikes" do

  end
end

if $0 == __FILE__
  TransportApp.start!
end