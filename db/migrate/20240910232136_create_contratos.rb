class CreateContratos < ActiveRecord::Migration[6.1]
  def change
    create_table :contratos do |t|
      t.references :interesse, null: false, foreign_key: true
      t.date :data, null: true
      t.string :status, null: true

      t.timestamps
    end
  end
end
