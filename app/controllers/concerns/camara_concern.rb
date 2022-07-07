require 'json'

module CamaraConcern

  def lista_deputados
    lista = get_request(API_CAMARA + "deputados")
    lista.map{|e| e["nome"].downcase! }
    lista
  end

  def deputados_por_estado(estado)
    lista_deputados.select{ |dep| dep['siglaUf']==estado }
  end

  def deputados_por_partido(partido)
    lista_deputados.select{ |dep| dep['siglaPartido']==partido }
  end

  def deputados_por_nome(nome)
    id_legis = get_request(LEGISLATURA).first['id']
    nome_parseado = URI.parse(CGI.escape(nome))
    url = API_CAMARA + "deputados?nome=#{nome_parseado}&idLegislatura=#{id_legis}&ordem=ASC&ordenarPor=nome"
    lista = get_request(url)
    lista
  end

  def nomes_deputados(hash = lista_deputados)
    hash.map{ |dep| dep['nome'] }.join("\n")
  end

  def dados_deputado(deputado)
    info_deputado = get_request(API_CAMARA + "deputados/#{deputado["id"]}")
    montar_mensagem(deputado, info_deputado)
  end

  private

  def get_request(url)
    response = Faraday.get(url)
    return response.body unless response.headers['Content-Type'].include?('application/json')
    page = JSON.parse(response.body)
    page['dados']
  end

  def montar_mensagem(deputado, info_deputado)
    gastos_deputado = gastos(deputado["id"])
    mensagem = ""
    mensagem.concat(t('.nome_civil', nome: info_deputado['nomeCivil']))
    mensagem.concat(t('.cpf', cpf: info_deputado['cpf']))
    mensagem.concat(t('.partido', partido: deputado["siglaPartido"]))
    mensagem.concat(t('.estado', estado: deputado["siglaUf"]))
    mensagem.concat(t('.email', email: deputado["email"]))
    mensagem.concat(t('.telefone', telefone: info_deputado['ultimoStatus']['gabinete']['telefone']))
    mensagem.concat(t('.gastos', nome: deputado['nome'], ano: Time.now.year))
    mensagem.concat(t('.ceap', ceap: gastos_deputado.first))
    mensagem.concat(t('.verba_gab', verba_gab: gastos_deputado.second))
    mensagem.concat(t('.link_dep', id: deputado["id"]))
    mensagem.concat(t('.link_gastos'))
    mensagem.concat(t('.link_ceap'))

    mensagem
  end

  def gastos(id)
    url = "https://www.camara.leg.br/deputados/#{id}"
    response = get_request(url)
    html = Nokogiri::HTML(response)
    list = html.css('table').text.delete(' ').lines.select{ |el| el!="\n" }
    list.delete_at(3)                             # remove a primeira elemento que contem o texto "TotalGasto\n"
    resposta = []
    resposta << list[3].chop
    index = list.find_index("TotalGasto\n") + 1   # procura o próximo elemento "TotalGasto\n", retorna seu indice e adiciona 1
    resposta << list[index].chop                  # pesquisa o valor gasto com verba de gabinete e remove o \n no final da string
    resposta
  end
end