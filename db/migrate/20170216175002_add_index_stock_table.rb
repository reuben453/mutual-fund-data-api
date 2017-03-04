class AddIndexStockTable < ActiveRecord::Migration[5.0]
  def up
    transaction do
      create_table :stocks do |t|
        t.string :name, :null => false
        t.timestamps
      end
      add_index :stocks, :name

      create_table :share_prices do |t|
        t.integer :stock_id, null: false
        t.decimal :open
        t.decimal :high
        t.decimal :low
        t.decimal :close
        t.date :date, null: false
      end
      add_foreign_key :share_prices, :stocks

      add_index :share_prices, :date, unique: true
    end
  end

  def down
    drop_table :stocks if table_exists?(:stocks)
  end
end
