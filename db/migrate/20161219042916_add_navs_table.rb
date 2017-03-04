class AddNavsTable < ActiveRecord::Migration[5.0]
  def up
  	transaction do
  		rename_table :mfs, :navs

  		create_table :mutual_funds do |t|
  			t.string :code, :null => false
  			t.string :name, :null => false
  			t.string :isin_growth
  			t.string :isin_div_reinvestment
  			t.string :mf_house_name, :null => false
  			t.string :scheme_category
  			t.timestamps
  		end

  		add_index :mutual_funds, :code, :unique => true
  		add_index :mutual_funds, :name
  		add_index :mutual_funds, :isin_growth
  		add_index :mutual_funds, :isin_div_reinvestment

  		execute <<-SQL
  			INSERT INTO mutual_funds (code, name, isin_growth, isin_div_reinvestment, mf_house_name, scheme_category, created_at, updated_at) SELECT scheme_code, scheme_name, isin_growth, isin_div_reinvestment, mf_house_name, scheme_category, created_at, updated_at from navs;
  		SQL

  		add_column :navs, :mutual_fund_id, :integer
	  	add_foreign_key :navs, :mutual_funds
	  	add_index :navs, [:mutual_fund_id, :date], :unique => true

  		execute <<-SQL
  			UPDATE navs SET mutual_fund_id = (SELECT id FROM mutual_funds WHERE code = navs.scheme_code);
  		SQL

  		change_column_null :navs, :mutual_fund_id, false

  		remove_column :navs, :scheme_code
  		remove_column :navs, :scheme_name
  		remove_column :navs, :isin_growth
  		remove_column :navs, :isin_div_reinvestment
  		remove_column :navs, :mf_house_name
  		remove_column :navs, :scheme_category

  	end
  end

  def down
  	transaction do
  		rename_table :navs, :mfs

  		drop_table :mutual_funds
  	end
  end
end
