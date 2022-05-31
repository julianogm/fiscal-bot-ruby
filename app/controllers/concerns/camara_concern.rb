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

  def nomes_deputados(hash)
    hash.map{ |dep| dep['nome'] }.join("\n")
  end

  def foto_deputado(nome_deputado)
    lista_deputados.select{|e| e['nome']==nome_deputado}.first['urlFoto']
  end

  def dados_deputado(nome_deputado)
    deputado = lista_deputados.select{ |e| e['nome']==nome_deputado }.first
    mensagem = ""
    mensagem.concat(t('.content', text: deputado['nome'])+"\n")
    mensagem.concat("email: #{deputado["email"]}\n")
    mensagem.concat("Partido: #{deputado["siglaPartido"]}\n")
    mensagem.concat("Estado: #{deputado["siglaUf"]}\n\n")
    mensagem.concat("CEAP utilizada em #{Time.now.year}: R$ #{despesas_deputado(deputado["id"])}")

    mensagem.concat("\n\n\nMais informações: https://www.camara.leg.br/deputados/#{deputado["id"]}\n")
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
    conn = Faraday.new(url) do |f|
      f.request :json
      f.response :json
      f.adapter :net_http
    end
    conn.get.body['dados']
  end
end