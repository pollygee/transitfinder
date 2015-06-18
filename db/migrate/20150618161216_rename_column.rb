class RenameColumn < ActiveRecord::Migration
  def change
    rename_column :bikes, :latitue, :latitude
    rename_column :trains, :latitue, :latitude
  end
end
