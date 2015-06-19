require 'sinatra/base'
require 'tilt/erubis' # Fixes a warning
#require 'rack/cors'
require 'pry'
require './db/setup'
require './lib/all'
require 'haversine'

class TransportApp < Sinatra::Base

  def how_far a_long, a_lat, b_long, b_lat
    dis = Haversine.distance(a_long, a_lat, b_long, b_lat)
    dis.to_miles
  end

  get "/closest_train" do
    user_long = params["long"].to_f
    user_lat =  params["lat"].to_f

    all_trains = Train.all
    # trains_and_distance = {}
    # all_trains.each do |train|
    #   distance_to_user = how_far(user_long, user_lat, train.longitude, train.latitude)
    #   trains_and_distance[train] = distance_to_user
    # end
    # binding.pry
    # return trains_and_distance
  end

  get "/train_info"  do

  end

  get "/closest_bike" do

  end

  get "bike_info" do

  end


end

if $0 == __FILE__
  TransportApp.start!
end