class ChangeNavDateDataType < ActiveRecord::Migration[5.0]
  def up
    transaction do
      change_table :navs do |t|
        t.change :date, :date, :null => false
      end
    end
  end

  def down
    transaction do
      change_table :navs do |t|
        t.change :date, :timestamp, :null => false
      end
    end
  end
end
