class CreateIcts < ActiveRecord::Migration[7.2]
  def change
    create_table :icts do |t|
      t.string :nome, null: false
      t.string :cnpj, null: false
      t.string :email, null: false
      t.string :endereco, null: false
      t.string :foto_perfil, null: false

      t.timestamps
    end
    add_index :icts, :cnpj, unique: true
  end
end