class CreateResponsaveis < ActiveRecord::Migration[6.1]
  def change
    create_table :responsaveis do |t|
      t.references :empresa, null: true, foreign_key: true
      t.references :ict, null: true, foreign_key: true
      t.string :nome, null: false
      t.string :cargo, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :tipo, null: false

      t.timestamps
    end
    add_index :responsaveis, :email, unique: true
  end
end
