class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.string :file_name
      t.integer :img_url, :default => 1
      t.timestamps
    end
  end
end
