module BotHelper
  def estados_buttons
    buttons = []
    UF.each do |k, v|
      buttons << [{text: v, callback_data: 'no_alert'}]
    end
    buttons
  end

  def partidos_buttons
    buttons = []
    siglas_partidos.each do |sigla|
      buttons << [{text: sigla, callback_data: 'no_alert'}]
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
    lista_partidos.map {|e| e['sigla']}
  end
end