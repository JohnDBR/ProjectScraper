class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      #t.string :email
      # t.string :password_digest
      t.string :full_name
      t.string :username
      t.integer :role, default: 0
      t.integer :storage_id

      t.timestamps
    end
  end
end
