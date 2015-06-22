require 'httparty'
require 'pry'
require './db/setup'
require './lib/all'

data = HTTParty.get("https://api.wmata.com/Bus.svc/json/jStops", query: { api_key: "d311c928b8364eff80d7462f7938b2b1" })
all_stations = data["Stops"]

all_stations.each do |station|
  Bus.create! name: station["Name"], stop_id: station["StopID"], routes: station["Routes"], latitude: station["Lat"],
  longitude: station["Lon"]
end