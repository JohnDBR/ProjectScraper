class CreateLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :links do |t|
      t.string :secret
      t.date :expire_at
      t.integer :group_id

      t.timestamps
    end
  end
end
