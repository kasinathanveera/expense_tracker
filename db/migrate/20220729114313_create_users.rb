# Migration file
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :department
      t.integer :status
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end

