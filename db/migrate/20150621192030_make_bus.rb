class MakeBus < ActiveRecord::Migration
  def change
    create_table "buses" do |t|
      t.string "name"
      t.integer "stop_id"
      t.string "routes"
      t.decimal "latitue", :precision => 15, :scale => 10
      t.decimal "longitude", :precision => 15, :scale => 10
    end
  end
end
