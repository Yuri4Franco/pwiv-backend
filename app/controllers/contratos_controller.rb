class ContratosController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_user_access, only: [:index]
  before_action :set_contrato, only: [:show, :update, :destroy]

  # GET /contratos
  def index
    if @current_responsavel.empresa?
      # Contratos associados aos projetos da empresa
      @contratos = Contrato.joins(interesse: :projeto)
                           .where(projetos: { empresa_id: @current_responsavel.empresa_id })
                           .includes(interesse: { projeto: :empresa, responsavel: :ict })
    elsif @current_responsavel.ict?
      # Contratos associados aos interesses do ICT
      @contratos = Contrato.joins(interesse: :responsavel)
                           .where(responsaveis: { id: @current_responsavel.id })
                           .includes(interesse: { projeto: :empresa, responsavel: :ict })
    else
      render json: { error: "Acesso negado" }, status: :forbidden
      return
    end

    render json: @contratos.as_json(
      include: {
        interesse: {
          include: {
            projeto: {
              only: [:id, :nome],
              include: { empresa: { only: [:id, :nome, :foto_perfil] } },
            },
            responsavel: {
              only: [:id, :nome],
              include: { ict: { only: [:id, :nome, :foto_perfil] } },
            },
          },
        },
      },
    )
  end

  # GET /contratos/:id
  def show
    render json: @contrato, include: { interesse: { include: [:projeto, :responsavel] } }
  end

  # POST /contratos
  # POST /contratos
  def create
    @interesse = Interesse.find(params[:interesse_id])

    if @interesse.contrato.present?
      render json: { error: "Contrato já existe para este interesse" }, status: :unprocessable_entity
      return
    end

    @contrato = Contrato.new(interesse: @interesse, data: Date.today, status: "Ativo")

    if @contrato.save
      # Atualiza o status do projeto e do interesse
      @interesse.update(status: "aceito")
      @interesse.projeto.update(status: "Em andamento")

      # Rejeita outros interesses no mesmo projeto
      Interesse.where(projeto_id: @interesse.projeto_id)
               .where.not(id: @interesse.id)
               .update_all(status: "rejeitado")

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

  def authorize_user_access
    unless @current_responsavel.empresa? || @current_responsavel.ict?
      render json: { error: "Acesso negado" }, status: :forbidden
    end
  end
end
