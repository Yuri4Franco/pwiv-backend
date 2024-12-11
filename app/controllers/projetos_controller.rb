class ProjetosController < ApplicationController
  before_action :authorize_request
  before_action :set_projeto, only: [:show, :update, :destroy]
  before_action :check_permission, only: [:show, :update, :destroy]

  # GET /projetos
  def index
    if @current_responsavel.empresa?
      @projetos = current_empresa.projetos
    elsif @current_responsavel.ict?
      @projetos = Projeto.where(status: "Aberto") # Projetos com status "aberto"
        .includes(:empresa) # Inclui informações da empresa
    end

    # Aplicar os filtros de nome e prioridade
    @projetos = @projetos.where("nome ILIKE ?", "%#{params[:nome]}%") if params[:nome].present?
    @projetos = @projetos.where(prioridade: params[:prioridade]) if params[:prioridade].present?

    # Filtro de empresa apenas para ICTs
    if @current_responsavel.ict? && params[:empresa_id].present?
      @projetos = @projetos.where(empresa_id: params[:empresa_id])
    end

    render json: @projetos.as_json(include: { empresa: { only: [:nome, :foto_perfil] } })
  end

  # GET /projetos/:id
  def show
    render json: @projeto.as_json(include: { empresa: { only: [:nome, :foto_perfil] } })
  end

  # POST /projetos
  def create
    @projeto = current_empresa.projetos.build(projeto_params)

    if @projeto.save
      render json: @projeto, status: :created
    else
      render json: @projeto.errors, status: :unprocessable_entity
    end
  end

  # PUT /projetos/:id
  def update
    if @projeto.update(projeto_params)
      render json: @projeto
    else
      render json: @projeto.errors, status: :unprocessable_entity
    end
  end

  # DELETE /projetos/:id
  def destroy
    if @projeto.status != "Aberto"
      render json: { error: "Somente projetos com status 'aberto' podem ser excluídos" }, status: :forbidden
      return
    end

    @projeto.destroy
    head :no_content
  end

  private

  def set_projeto
    if @current_responsavel.empresa?
      @projeto = current_empresa.projetos.find(params[:id])
    elsif @current_responsavel.ict?
      @projeto = Projeto.where(status: "aberto").find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Projeto não encontrado" }, status: :not_found
  end

  def check_permission
    if @current_responsavel.empresa? && @projeto.empresa_id != @current_responsavel.empresa_id
      render json: { error: "Acesso negado" }, status: :forbidden
    end
  end

  def projeto_params
    params.require(:projeto).permit(:nome, :descricao, :data_inicio, :data_fim, :status, :prioridade)
  end

  def current_empresa
    @current_empresa ||= @current_responsavel.empresa
  end
end
