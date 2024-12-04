class ContratosController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_empresa
  before_action :set_contrato, only: [:show, :update, :destroy]

  # GET /contratos
  def index
    @contratos = Contrato.includes(interesse: [:projeto, :responsavel]).all
    render json: @contratos, include: { interesse: { include: [:projeto, :responsavel] } }
  end

  # GET /contratos/:id
  def show
    render json: @contrato, include: { interesse: { include: [:projeto, :responsavel] } }
  end

  # POST /contratos
  def create
    @contrato = Contrato.new(contrato_params)
    @contrato.data = Date.today
    @contrato.status = "pendente" # Status inicial padrão

    if @contrato.save
      render json: @contrato, status: :created
    else
      render json: @contrato.errors, status: :unprocessable_entity
    end
  end

  # PUT /contratos/:id
  def update
    if @contrato.update(contrato_params)
      render json: @contrato
    else
      render json: @contrato.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contratos/:id
  def destroy
    @contrato.destroy
    head :no_content
  end

  private

  def set_contrato
    @contrato = Contrato.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Contrato não encontrado" }, status: :not_found
  end

  def contrato_params
    params.permit(:interesse_id, :status)
  end

  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    if token
      begin
        decoded = JsonWebToken.decode(token)
        @current_empresa = Empresa.find(decoded[:empresa_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Empresa não encontrada" }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: "Token inválido" }, status: :unauthorized
      end
    else
      render json: { error: "Token de autenticação ausente" }, status: :unauthorized
    end
  end

  def authorize_empresa
    render json: { error: "Acesso negado" }, status: :forbidden unless @current_empresa.present?
  end
end
