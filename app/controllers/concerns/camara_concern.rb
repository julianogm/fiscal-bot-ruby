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

  def foto_deputado(id_deputado)
    lista_deputados.select{|e| e['id']==id_deputado}.first['urlFoto']
  end

  def dados_deputado(deputado)
    #deputado = lista_deputados.select{ |e| e['nome']==nome_deputado }.first
    info_deputado = get_request(API_CAMARA + "deputados/#{deputado["id"]}")
    gastos_deputado = gastos(deputado["id"])
    mensagem = ""
    mensagem.concat("Nome civil: #{info_deputado['nomeCivil']}\n")
    mensagem.concat("CPF: #{info_deputado['cpf']}\n")
    mensagem.concat("Partido: #{deputado["siglaPartido"]}\n")
    mensagem.concat("Estado: #{deputado["siglaUf"]}\n")
    mensagem.concat("email: #{deputado["email"]}\n")
    mensagem.concat("telefone: (61) #{info_deputado['ultimoStatus']['gabinete']['telefone']}\n\n")

    mensagem.concat(t('.content', text: deputado['nome']) +" em #{Time.now.year}\n")
    mensagem.concat("Cota para o Exercício da Atividade Parlamentar (CEAP): R$ #{gastos_deputado.first}\n")
    mensagem.concat("Verba de Gabinete utilizada: R$ #{gastos_deputado.second}")
    mensagem.concat("\n\nMais informações: https://www.camara.leg.br/deputados/#{deputado["id"]}\n")

    mensagem.concat("\nSobre a CEAP: https://www2.camara.leg.br/transparencia/acesso-a-informacao/copy_of_perguntas-frequentes/cota-para-o-exercicio-da-atividade-parlamentar")

    mensagem
  end

  #API NAO RETORNA TODOS OS PARTIDOS, NECESSARIO FAZER VARIAS REQUISICOES
  def lista_partidos
    lista = []
    i = 0
    while true
      response = get_request(API_CAMARA + "partidos?pagina=#{i+=1}")
      break if response.empty?
      lista << response
    end
    lista.flatten(1)    #nivela o array
  end

  def despesas_deputado(id)
    lista = []
    i = 0
    while true
      response = get_request(API_CAMARA + "deputados/#{id}/despesas?ano=#{Time.now.year}&pagina=#{i+=1}")
      break if response.empty?
      lista << response
    end
    lista.flatten!(1)
    lista.map{ |i| i['valorLiquido'] }.sum
  end

  def get_request(url)
    response = Faraday.get(url)
    return response.body unless response.headers['Content-Type'].include?('application/json')
    page = JSON.parse(response.body)
    page['dados']
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