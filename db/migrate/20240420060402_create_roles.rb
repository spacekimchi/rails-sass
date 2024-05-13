class CreateRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :roles do |t|
      t.integer :name
      t.string :description

      t.timestamps
    end

    add_index :roles, :name, unique: true
  end
end
