class CreateUserRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :user_roles do |t|
      t.integer :role
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
