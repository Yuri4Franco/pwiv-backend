class EmpresasController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_admin
  before_action :set_empresa, only: [:show, :update, :destroy]

  # GET /empresas
  def index
    @empresas = Empresa.all
    render json: @empresas
  end

  # GET /empresas/:id
  def show
    render json: @empresa
  end

  # POST /empresas
  def create
    @empresa = Empresa.new(empresa_params.except(:foto_perfil))

    if params[:foto_perfil].present?
      @empresa.foto_perfil = save_image(params[:foto_perfil], @empresa.nome)
    end

    if @empresa.save
      Rails.logger.info "Empresa criada com sucesso, sem erros."
      Rails.logger.info "Enviando e-mail para: #{@empresa.email}"
      EmpresaMailer.empresa_created(@empresa).deliver_now
      render json: @empresa, status: :created
    else
      Rails.logger.info "Erro ao criar a empresa: #{@empresa.errors.full_messages}"
      render json: @empresa.errors, status: :unprocessable_entity
    end
  end

  # PUT /empresas/:id
  def update
    if @empresa.update(empresa_params.except(:foto_perfil))
      if params[:foto_perfil].present?
        # Remove a imagem antiga, se existir
        remove_image(@empresa.foto_perfil) if @empresa.foto_perfil.present?

        # Salva a nova imagem
        @empresa.update(foto_perfil: save_image(params[:foto_perfil], @empresa.nome))
      end
      render json: @empresa
    else
      render json: @empresa.errors, status: :unprocessable_entity
    end
  end

  # DELETE /empresas/:id
  def destroy
    # Remove a imagem associada antes de deletar a empresa
    remove_image(@empresa.foto_perfil) if @empresa.foto_perfil.present?

    @empresa.destroy
    head :no_content
  end

  private

  def set_empresa
    @empresa = Empresa.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Empresa não encontrada" }, status: :not_found
  end

  def empresa_params
    params.permit(:nome, :cnpj, :email, :endereco, :foto_perfil)
  end

  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    if token
      begin
        decoded = JsonWebToken.decode(token)
        @current_responsavel = Responsavel.find(decoded[:responsavel_id])
        Rails.logger.info "Usuário autenticado: #{@current_responsavel.email}"
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Usuário não encontrado" }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: "Token inválido" }, status: :unauthorized
      end
    else
      render json: { error: "Token de autenticação ausente" }, status: :unauthorized
    end
  end

  def authorize_admin
    render json: { error: "Acesso negado" }, status: :forbidden unless @current_responsavel&.admin?
  end

  # Salva a foto de perfil e retorna o caminho relativo para salvar no banco
  def save_image(uploaded_image, empresa_nome)
    file_extension = File.extname(uploaded_image.original_filename)
    file_name = "#{empresa_nome.parameterize}#{file_extension}"
    file_path = Rails.root.join("app", "images", file_name)

    # Garante que o diretório existe
    FileUtils.mkdir_p(File.dirname(file_path))

    # Salva o arquivo no diretório especificado
    File.open(file_path, "wb") do |file|
      file.write(uploaded_image.read)
    end

    # Retorna o caminho relativo
    "app/images/#{file_name}"
  end

  # Remove a imagem associada
  def remove_image(image_path)
    full_path = Rails.root.join(image_path)
    File.delete(full_path) if File.exist?(full_path)
  end
end
