class CreateTrain < ActiveRecord::Migration
  def change
    create_table "trains" do |t|
      t.string "name"
      t.string "address"
      t.string "code"
      t.decimal "latitue", :precision => 15, :scale => 10
      t.decimal "longitude", :precision => 15, :scale => 10
    end

    create_table "bikes" do |t|
      t.integer "station_id"
      t.string "location_name"
      t.decimal "latitue", :precision => 15, :scale => 10
      t.decimal "longitude", :precision => 15, :scale => 10
    end
  end
end
