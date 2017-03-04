class AddMfTable < ActiveRecord::Migration[5.0]
  def up
  	create_table :mfs do |t|
  		t.string :scheme_code, :null => false
  		t.string :mf_house_name
  		t.string :scheme_category
  		t.string :isin_growth
  		t.string :isin_div_reinvestment
  		t.string :scheme_name, :null => false
  		t.decimal :net_asset_value, :null => false
  		t.decimal :repurchase_price
  		t.decimal :sale_price
  		t.timestamp :date, :null => false
  		t.timestamps
  	end

  	add_index :mfs, [:scheme_code, :date], unique: true

  end

  def down
  	transaction do
  		drop_table :mfs
  	end
  end
end
