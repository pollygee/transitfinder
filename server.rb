require 'sinatra/base'
require 'tilt/erubis' # Fixes a warning
#require 'rack/cors'
require 'pry'
require './db/setup'
require './lib/all'
require 'haversine'
require 'httparty'

class TransportApp < Sinatra::Base

  def how_far a_long, a_lat, b_long, b_lat
    dis = Haversine.distance(a_long, a_lat, b_long, b_lat)
    dis.to_miles
  end

  get "/closest_train" do
    user_long = params["long"].to_f
    user_lat =  params["lat"].to_f

    all_trains = Train.all
    trains_and_distance = {}
    all_trains.each do |train|
      distance_to_user = how_far(user_long, user_lat, train.longitude, train.latitude)
      trains_and_distance[train] = distance_to_user
    end
    sorted_list = trains_and_distance.sort_by {|train, distance| distance}
    winner_list = []
    winner_list << sorted_list.shift
    winner_list << sorted_list.shift
    winner_list << sorted_list.shift
    winner_list.to_json

  end

  get "/train_info/:station"  do
    query_station  = params[:station]
    binding.pry
    station_info   = HTTParty.get("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/'All'", query: { api_key: "d311c928b8364eff80d7462f7938b2b1" })
    destination    = station_info["DestinationName"]
    line_color     = station_info["Line"]
    time_to_depart = station_info["Min"]
    final_information = {destination: destination, line_color: line_color, time_to_depart: time_to_depart}

  end

  get "/closest_bike" do
    
  end

  get "bike_info" do
    
  end
end

if $0 == __FILE__
  TransportApp.start!
end