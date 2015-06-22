require 'sinatra/base'
require 'tilt/erubis' 
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
    t.trains_live_data list
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
  end
end



if $0 == __FILE__
  TransportApp.start!
end