# Verifica se a empresa já existe antes de criar
empresa = Empresa.find_or_create_by!(
  cnpj: "12345678901234",
) do |e|
  e.nome = "Empresa Admin"
  e.email = "contato@admin.com"
  e.endereco = "Rua Teste, 123, Bairro Teste, Cidade Teste, Estado Teste, 12345-678"
  e.foto_perfil = "nome_da_imagem.png"
end

# unless empresa.imagem.attached?
#   empresa.imagem.attach(
#     io: File.open(Rails.root.join('app', 'images', 'nome_da_imagem.png')),
#     filename: 'nome_da_imagem.png',
#     content_type: 'image/png'
#   )
# end

# Cria um responsável comum associado à empresa, se não existir
Responsavel.find_or_create_by!(
  email: "responsavel@empresa.com",
) do |r|
  r.nome = "Responsável Comum"
  r.cargo = "Gerente de Projetos"
  r.password = "senha123"
  r.password_confirmation = "senha123"
  r.tipo = :empresa # Cria um usuário comum
  r.empresa = empresa
end

# Cria um administrador, se não existir
Responsavel.find_or_create_by!(
  email: "admin@empresa.com",
) do |r|
  r.nome = "Admin do Sistema"
  r.cargo = "Administrador"
  r.password = "admin123"
  r.password_confirmation = "admin123"
  r.tipo = :admin # Cria um usuário admin
  r.empresa = empresa
end

puts "Seed executado com sucesso!"
