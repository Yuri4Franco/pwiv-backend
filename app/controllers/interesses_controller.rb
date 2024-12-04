class InteressesController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_ict
  before_action :set_interesse, only: [:show, :update, :destroy]

  # GET /interesses
  def index
    @interesses = Interesse.all
    render json: @interesses
  end

  # GET /interesses/:id
  def show
    render json: @interesse
  end

  # POST /interesses
  def create
    @interesse = Interesse.new(interesse_params)
    @interesse.responsavel = @current_responsavel # Associa o responsável autenticado

    if @interesse.save
      render json: @interesse, status: :created
    else
      render json: @interesse.errors, status: :unprocessable_entity
    end
  end

  # PUT /interesses/:id
  def update
    if @interesse.update(interesse_params)
      render json: @interesse
    else
      render json: @interesse.errors, status: :unprocessable_entity
    end
  end

  # DELETE /interesses/:id
  def destroy
    @interesse.destroy
    head :no_content
  end

  private

  def set_interesse
    @interesse = Interesse.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Interesse não encontrado" }, status: :not_found
  end

  def interesse_params
    params.permit(:projeto_id, :proposta)
  end

  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    if token
      begin
        decoded = JsonWebToken.decode(token)
        @current_responsavel = Responsavel.find(decoded[:responsavel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Usuário não encontrado" }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: "Token inválido" }, status: :unauthorized
      end
    else
      render json: { error: "Token de autenticação ausente" }, status: :unauthorized
    end
  end

  def authorize_ict
    render json: { error: "Acesso negado" }, status: :forbidden unless @current_responsavel&.ict?
  end
end
