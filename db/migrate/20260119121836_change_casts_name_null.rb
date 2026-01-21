class ChangeCastsNameNull < ActiveRecord::Migration[7.2]
  def change
    change_column_null :casts, :name, false
  end
end
