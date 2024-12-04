class ResponsavelMailer < ApplicationMailer
  default from: "admin@exemplo.com"

  def dados_acesso
    @responsavel = params[:responsavel]
    mail(to: @responsavel.email, subject: "Seus dados de acesso")
  end
end
