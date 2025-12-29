class CreateModerators < ActiveRecord::Migration[7.2]
  def change
    create_table :moderators do |t|
      t.string :employee_number
      t.string :department

      t.timestamps
    end
  end
end
