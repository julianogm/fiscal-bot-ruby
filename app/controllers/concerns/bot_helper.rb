module BotHelper
  def estados_buttons
    buttons = []
    i = 0
    while i < 27 do
      buttons << [{text: UF.values[i], callback_data: UF.keys[i]},
                  {text: UF.values[i+1], callback_data: UF.keys[i+1]}]
      i = i + 2
    end
    buttons[13].pop
    buttons
  end

  def partidos_buttons
    buttons = []
    siglas_partidos.each do |sigla|
      buttons << [{text: sigla, callback_data: sigla}]
    end
    buttons
  end

  def lista_deputados
    conn = Faraday.new(API_CAMARA + "deputados?ordem=ASC&ordenarPor=nome") do |f|
      f.request :json
      f.response :json
      f.adapter :net_http
    end

    conn.get.body['dados']
  end

  #API NAO RETORNA TODOS OS PARTIDOS, NECESSARIO FAZER VARIAS REQUISICOES
  def lista_partidos
    lista = []
    i = 0
    while true
      conn = Faraday.new(API_CAMARA + "partidos?pagina=#{i+=1}") do |f|
        f.request :json
        f.response :json
        f.adapter :net_http
      end
      response = conn.get.body['dados']
      break if response.empty?
      lista << response
    end
    lista.flatten(1)    #nivela o array
  end

  def siglas_partidos
    lista_partidos.map { |e| e['sigla'] }
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
end