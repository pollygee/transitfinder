require 'httparty'
require 'pry'
require './db/setup'
require './lib/all'

data = HTTParty.get("http://www.capitalbikeshare.com/data/stations/bikeStations.xml", query: { api_key: "d311c928b8364eff80d7462f7938b2b1" })

all_stations = data["stations"]["station"]

all_stations.each do |station|
  Bike.create! station_id: station["id"], location_name: station["name"], latitude: station["lat"],
  longitude: station["long"]
end
