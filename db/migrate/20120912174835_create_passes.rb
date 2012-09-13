class CreatePasses < ActiveRecord::Migration
  def change
    create_table :passes do |t|
      t.string :pass_type_identifier
      t.string :serial_number
      t.hstore :data

      t.timestamps
    end

    add_index :passes, [:pass_type_identifier, :serial_number]
  end
end
