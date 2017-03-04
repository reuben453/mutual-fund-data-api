class TagKeywords < ActiveRecord::Migration[5.0]
  def up
    create_table :keywords do |t|
      t.text :name
      t.integer :tag_id, :null => false
      t.timestamps
    end

    create_table :tags do |t|
      t.text :name
      t.timestamps
    end
  end

  def down
    transaction do
      drop_table :keywords
      drop_table :tags
    end
  end
end
