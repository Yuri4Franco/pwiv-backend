class AuthenticationController < ApplicationController
  def login
    # Encontra o responsável pelo email
    @responsavel = Responsavel.find_by(email: params[:email])

    # Verifica a senha usando o `authenticate` de `has_secure_password`
    if @responsavel&.authenticate(params[:password])
      # Gera o token JWT
      token = JsonWebToken.encode(responsavel_id: @responsavel.id)
      # Retorna o token no JSON
      render json: {
               token: token,
               responsavel_id: @responsavel.id,
               empresa_id: @responsavel.empresa_id,
               ict_id: @responsavel.ict_id,
               tipo: @responsavel.tipo,
             }, status: :ok
    else
      # Retorna erro de autenticação
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
