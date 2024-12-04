class ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header
    decoded = JsonWebToken.decode(header)
    @current_responsavel = Responsavel.find(decoded[:responsavel_id]) if decoded # Busca o responsável pelo ID decodificado
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: "Unauthorized" }, status: :unauthorized
  end
end
