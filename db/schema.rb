# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_09_10_232136) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contratos", force: :cascade do |t|
    t.bigint "interesse_id", null: false
    t.date "data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interesse_id"], name: "index_contratos_on_interesse_id"
  end

  create_table "empresas", force: :cascade do |t|
    t.string "nome", null: false
    t.string "cnpj", null: false
    t.string "email", null: false
    t.string "endereco", null: false
    t.string "foto_perfil", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_empresas_on_cnpj", unique: true
  end

  create_table "icts", force: :cascade do |t|
    t.string "nome", null: false
    t.string "cnpj", null: false
    t.string "email", null: false
    t.string "endereco", null: false
    t.string "foto_perfil", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_icts_on_cnpj", unique: true
  end

  create_table "interesses", force: :cascade do |t|
    t.bigint "projeto_id", null: false
    t.bigint "responsavel_id", null: false
    t.string "proposta", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["projeto_id"], name: "index_interesses_on_projeto_id"
    t.index ["responsavel_id"], name: "index_interesses_on_responsavel_id"
  end

  create_table "projetos", force: :cascade do |t|
    t.string "nome", null: false
    t.text "descricao"
    t.string "status"
    t.string "prioridade"
    t.bigint "empresa_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["empresa_id"], name: "index_projetos_on_empresa_id"
  end

  create_table "responsaveis", force: :cascade do |t|
    t.bigint "empresa_id"
    t.bigint "ict_id"
    t.string "nome", null: false
    t.string "cargo", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "tipo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_responsaveis_on_email", unique: true
    t.index ["empresa_id"], name: "index_responsaveis_on_empresa_id"
    t.index ["ict_id"], name: "index_responsaveis_on_ict_id"
  end

  add_foreign_key "contratos", "interesses", column: "interesse_id"
  add_foreign_key "interesses", "projetos"
  add_foreign_key "interesses", "responsaveis"
  add_foreign_key "projetos", "empresas"
  add_foreign_key "responsaveis", "empresas"
  add_foreign_key "responsaveis", "icts"
end
