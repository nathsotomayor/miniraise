class CreateOfferings < ActiveRecord::Migration[8.1]
  def change
    create_table :offerings do |t|
      t.string :name, null: false
      t.integer :target_amount_cents, null: false
      t.integer :min_investment_cents, null: false

      t.timestamps
    end
  end
end
