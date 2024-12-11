class IctsController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_admin
  before_action :set_ict, only: [:show, :update, :destroy]

  # GET /icts
  def index
    @icts = Ict.all
    render json: @icts
  end

  # GET /icts/:id
  def show
    render json: @ict
  end

  # POST /icts
  def create
    @ict = Ict.new(ict_params.except(:foto_perfil))

    if params[:foto_perfil].present?
      @ict.foto_perfil = save_image(params[:foto_perfil], @ict.nome)
    end

    if @ict.save
      Rails.logger.info "ICT criada com sucesso, sem erros."
      render json: @ict, status: :created
    else
      Rails.logger.info "Erro ao criar a ICT: #{@ict.errors.full_messages}"
      render json: @ict.errors, status: :unprocessable_entity
    end
  end

  # PUT /icts/:id
  def update
    if @ict.update(ict_params.except(:foto_perfil))
      if params[:foto_perfil].present?
        # Remove a imagem antiga, se existir
        remove_image(@ict.foto_perfil) if @ict.foto_perfil.present?

        # Salva a nova imagem
        @ict.update(foto_perfil: save_image(params[:foto_perfil], @ict.nome))
      end
      render json: @ict
    else
      render json: @ict.errors, status: :unprocessable_entity
    end
  end

  # DELETE /icts/:id
  def destroy
    # Remove a imagem associada antes de deletar a ICT
    remove_image(@ict.foto_perfil) if @ict.foto_perfil.present?

    @ict.destroy
    head :no_content
  end

  private

  def set_ict
    @ict = Ict.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "ICT não encontrada" }, status: :not_found
  end

  def ict_params
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
    file_path = Rails.root.join("public", "images", file_name) # Salvar em public/images

    # Garante que o diretório existe
    FileUtils.mkdir_p(File.dirname(file_path))

    # Salva o arquivo no diretório especificado
    File.open(file_path, "wb") do |file|
      file.write(uploaded_image.read)
    end

    # Retorna o caminho relativo para o frontend acessar
    "/images/#{file_name}"
  end

  # Remove a imagem associada
  def remove_image(image_path)
    full_path = Rails.root.join(image_path)
    File.delete(full_path) if File.exist?(full_path)
  end
end
