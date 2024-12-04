class Interesse < ApplicationRecord
  belongs_to :projeto
  belongs_to :responsavel
  has_one :contrato
end
