class EmpresaMailer < ApplicationMailer
  def empresa_created(empresa)
    @empresa = empresa
    mail(to: @empresa.email, subject: "Empresa criada com sucesso!")
  end
end
