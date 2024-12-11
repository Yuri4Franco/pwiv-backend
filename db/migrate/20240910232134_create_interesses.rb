class CreateInteresses < ActiveRecord::Migration[6.1]
  def change
    create_table :interesses do |t|
      t.references :projeto, null: false, foreign_key: true
      t.references :responsavel, null: false, foreign_key: true
      t.string :proposta, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
