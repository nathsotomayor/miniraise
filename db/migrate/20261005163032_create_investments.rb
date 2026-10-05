class CreateInvestments < ActiveRecord::Migration[8.1]
  def change
    create_table :investments do |t|
      t.references :offering, null: false, foreign_key: true
      t.string :investor_name, null: false
      t.string :investor_email, null: false
      t.integer :amount_cents, null: false

      t.timestamps
    end
  end
end
