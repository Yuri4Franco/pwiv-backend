class ProjetosController < ApplicationController
  before_action :authorize_request
  before_action :set_projeto, only: [:show, :update, :destroy]
  before_action :check_permission, only: [:show, :update, :destroy]

  # GET /projetos
  def index
    if @current_responsavel.empresa? # Se o responsável for de uma empresa
      @projetos = current_empresa.projetos
    elsif @current_responsavel.ict? # Se o responsável for de uma ICT
      @projetos = Projeto.where(contrato: nil) # Projetos que não têm contrato
    end

    # Aplicar os filtros de nome e prioridade
    @projetos = @projetos.where("nome ILIKE ?", "%#{params[:nome]}%") if params[:nome].present?
    @projetos = @projetos.where(prioridade: params[:prioridade]) if params[:prioridade].present?

    # Filtro de empresa apenas para ICTs
    if @current_responsavel.ict? && params[:empresa_id].present?
      @projetos = @projetos.where(empresa_id: params[:empresa_id])
    end

    render json: @projetos
  end

  # GET /projetos/:id
  def show
    render json: @projeto
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
    @projeto.destroy
    head :no_content
  end

  private

  # Encontra o projeto pelo ID
  def set_projeto
    if @current_responsavel.empresa?
      @projeto = current_empresa.projetos.find(params[:id])
    elsif @current_responsavel.ict?
      @projeto = Projeto.find(params[:id])
      render json: { error: "Acesso negado" }, status: :forbidden if @projeto.contrato.present?
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Projeto não encontrado" }, status: :not_found
  end

  # Verifica se o projeto pertence à empresa ou pode ser visto pela ICT
  def check_permission
    if @current_responsavel.empresa? && @projeto.empresa_id != @current_responsavel.empresa_id
      render json: { error: "Acesso negado" }, status: :forbidden
    elsif @current_responsavel.ict? && @projeto.contrato.present?
      render json: { error: "Acesso negado" }, status: :forbidden
    end
  end

  # Define os parâmetros permitidos
  def projeto_params
    params.require(:projeto).permit(:nome, :descricao, :data_inicio, :data_fim, :status, :prioridade)
  end

  # Retorna a empresa do responsável autenticado
  def current_empresa
    @current_empresa ||= @current_responsavel.empresa
  end
end
