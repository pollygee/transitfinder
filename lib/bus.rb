class Bus < ActiveRecord::Base
  def distance_to user_long, user_lat
    Haversine.distance(user_long, user_lat, self.long, self.lat).to_miles
  end
end