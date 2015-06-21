require 'httparty'
require 'json'
require 'pry'

class WmataAPI
  @token = File.read "./token.txt"
  def how_far a_long, a_lat, b_long, b_lat
    dis = Haversine.distance(a_long, a_lat, b_long, b_lat)
    dis.to_miles
  end

  def train_station_info station_code
    @station_info = HTTParty.get("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{station_code}", query: { api_key: "#{@token}" })
  end

  def trains_w_distances user_long, user_lat
    all_trains = Train.all
    trains_and_distance = []
    all_trains.each do |train|
      train_info = train.attributes
      distance_to_user = how_far(user_long, user_lat, train.longitude, train.latitude)
      train_info[:distance] = distance_to_user
      trains_and_distance << train_info
    end
    trains_and_distance
  end

  def sorted_3 list
    sorted = list.sort_by {|hsh| hsh[:distance]}
    sorted.first(3)
  end

  def trains_live_data three_trains
    three_trains.each do |station|
      #station_info   = HTTParty.get("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{station_code}", query: { api_key: "#{token}" })      
      station[:next_train] = train_station_info station["code"]
    end
    three_trains.to_json
  end

end




