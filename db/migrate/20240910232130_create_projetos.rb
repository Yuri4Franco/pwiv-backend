class CreateProjetos < ActiveRecord::Migration[6.1]
  def change
    create_table :projetos do |t|
      t.string :nome, null: false
      t.text :descricao
      t.string :status
      t.string :prioridade
      t.references :empresa, null: false, foreign_key: true

      t.timestamps
    end
  end
end
