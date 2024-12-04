class Empresa < ApplicationRecord
  has_many :responsaveis
  has_many :projetos
end
