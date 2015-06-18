class AddColumn < ActiveRecord::Migration
  def change
    add_column :bikes, :station_id, :integer
  end
end
