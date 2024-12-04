class Responsavel < ApplicationRecord
  self.table_name = "responsaveis"
  belongs_to :empresa, optional: true
  belongs_to :ict, optional: true
  has_many :interesses
  has_secure_password
  enum tipo: { admin: 0, empresa: 1, ict: 2 }

  def admin?
    self.tipo == "admin"
  end
end
