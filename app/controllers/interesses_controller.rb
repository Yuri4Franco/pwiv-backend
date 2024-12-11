class InteressesController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_access, only: [:index]
  before_action :set_interesse, only: [:show, :update, :destroy]

  # GET /interesses
  def index
    if @current_responsavel.empresa?
      # Usuário Empresa vê apenas interesses nos seus projetos que não possuem contratos
      @interesses = Interesse.joins(:projeto)
                             .left_joins(:contrato)
                             .where(projetos: { empresa_id: @current_responsavel.empresa_id })
                             .where(contratos: { id: nil }) # Garante que o contrato é nulo
                             .includes(responsavel: [:ict])
    elsif @current_responsavel.ict?
      # Usuário ICT vê apenas interesses associados aos seus projetos
      @interesses = Interesse.joins(:projeto)
                             .left_joins(:contrato)
                             .where(contratos: { id: nil }) # Garante que o contrato é nulo
                             .where(responsavel_id: @current_responsavel.id) # Filtra interesses do ICT atual
                             .includes(projeto: { empresa: :responsaveis })
    else
      render json: { error: "Acesso negado" }, status: :forbidden
      return
    end

    render json: @interesses.as_json(
      include: {
        responsavel: {
          only: [:id, :nome],
          include: { ict: { only: [:id, :nome, :foto_perfil] } },
        },
        projeto: {
          only: [:id, :nome],
          include: { empresa: { only: [:id, :nome] } },
        },
      },
    )
  end

  # GET /interesses/:id
  def show
    render json: @interesse
  end

  # POST /interesses
  def create
    @interesse = Interesse.new(interesse_params)
    @interesse.responsavel = @current_responsavel # Associa o responsável autenticado
    @interesse.status = "pendente"

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
    params.permit(:projeto_id, :proposta, :status)
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

  def authorize_access
    unless @current_responsavel.empresa? || @current_responsavel.ict?
      render json: { error: "Acesso negado" }, status: :forbidden
    end
  end
end
