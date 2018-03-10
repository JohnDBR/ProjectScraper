class CreateStorages < ActiveRecord::Migration[5.1]
  def change
    create_table :storages do |t|
   		t.string :path
   		t.integer :token_id

      t.timestamps
    end
  end
end
