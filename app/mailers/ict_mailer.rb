class IctMailer < ApplicationMailer
  def ict_created(ict)
    @ict = ict
    mail(to: @ict.email, subject: "ICT criada com sucesso!")
  end
end
