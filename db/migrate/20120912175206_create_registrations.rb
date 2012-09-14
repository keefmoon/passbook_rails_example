class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.integer :pass_id
      t.string :device_library_identifier
      t.string :push_token

      t.timestamps
    end

    add_index :registrations, :device_library_identifier
  end
end
