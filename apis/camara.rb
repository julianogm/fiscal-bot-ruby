require 'faraday'

url_deputados = 'https://dadosabertos.camara.leg.br/api/v2/deputados'

def deputados
  connection
end

def deputado(id = nil, nome = nil)
  url_deputado = url_deputados + '/' + id
end

def connection(url = url_deputados)
  conn = Faraday.new(url) do |f|
    f.response :json # decode response bodies as JSON
  end

  conn.get.body['dados']
end