class CreateMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :members do |t|
      t.string :alias
      t.integer :group_id
      t.integer :user_id
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
