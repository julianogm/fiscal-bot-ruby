require 'json'

module CamaraConcern

  def lista_deputados
    get_request(API_CAMARA + "deputados")
  end

  def deputados_por_estado(estado)
    lista_deputados.select{ |dep| dep['siglaUf']==estado }
  end

  def deputados_por_partido(partido)
    lista_deputados.select{ |dep| dep['siglaPartido']==partido }
  end

  def nomes_deputados(hash = lista_deputados)
    hash.map{ |dep| dep['nome'] }.join("\n")
  end

  def foto_deputado(nome_deputado)
    lista_deputados.select{|e| e['nome']==nome_deputado}.first['urlFoto']
  end

  def dados_deputado(nome_deputado)
    deputado = lista_deputados.select{ |e| e['nome']==nome_deputado }.first
    info_deputado = get_request(API_CAMARA + "deputados/#{deputado["id"]}")
    mensagem = ""
    mensagem.concat(t('.content', text: deputado['nome'])+"\n")
    mensagem.concat("Nome civil: #{info_deputado['nomeCivil']}\n")
    mensagem.concat("CPF: #{info_deputado['cpf']}\n")
    mensagem.concat("Partido: #{deputado["siglaPartido"]}\n")
    mensagem.concat("Estado: #{deputado["siglaUf"]}\n")
    mensagem.concat("email: #{deputado["email"]}\n")
    mensagem.concat("telefone: (61) #{info_deputado['ultimoStatus']['gabinete']['telefone']}\n\n")
    mensagem.concat("Cota para o Exercício da Atividade Parlamentar (CEAP) utilizada em #{Time.now.year}: R$ #{despesas_deputado(deputado["id"])}")

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

  def verba_gabinete(id)
    url = "https://www.camara.leg.br/deputados/#{id}"
    response = get_request(url)
    html = Nokogiri::HTML(response)
    list = html.css('table').text.delete(' ').lines.select{ |el| el!="\n" }
    list[34].chop
  end
end