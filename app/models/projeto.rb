class Projeto < ApplicationRecord
  belongs_to :empresa
  has_many :interesses, class_name: "Interesse"
  has_one :contrato
end
