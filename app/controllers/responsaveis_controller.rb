class ResponsaveisController < ApplicationController
  before_action :authorize_admin
  before_action :set_responsavel, only: [:show, :update, :destroy]

  # GET /responsaveis
  def index
    @responsaveis = Responsavel.all
    render json: @responsaveis
  end

  # GET /responsaveis/:id
  def show
    render json: @responsavel
  end

  # POST /responsaveis
  def create
    @responsavel = Responsavel.new(responsavel_params)

    if @responsavel.save
      ResponsavelMailer.with(responsavel: @responsavel).dados_acesso.deliver_now
      render json: @responsavel, status: :created
    else
      render json: @responsavel.errors, status: :unprocessable_entity
    end
  end

  # PUT /responsaveis/:id
  def update
    if @responsavel.update(responsavel_params)
      render json: @responsavel
    else
      render json: @responsavel.errors, status: :unprocessable_entity
    end
  end

  # DELETE /responsaveis/:id
  def destroy
    @responsavel.destroy
    head :no_content
  end

  private

  def set_responsavel
    @responsavel = Responsavel.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Responsável não encontrado" }, status: :not_found
  end

  def responsavel_params
    params.permit(:nome, :cargo, :email, :password, :password_confirmation, :empresa_id, :ict_id, :tipo)
  end

  def authorize_admin
    render json: { error: "Acesso negado" }, status: :forbidden unless @current_responsavel.admin?
  end
end
