# Fiscal Bot


Bem vindo ao Bot Fiscal.
Esse é um bot do telegram de consultas a [api da câmara do deputados](https://dadosabertos.camara.leg.br/swagger/api.html) do Brasil.

Você pode testar o bot pesquisando @fiscal_politico_bot no telegram, ou clicando [aqui](http://t.me/fiscal_politico_bot).

Requisitos para executar:  
ruby 3.1.2  
  
Gems utilizadas:  
rails 7.0.2  
telegram-bot 0.15.6  
faraday 2.3  


<!--
<img src='https://img.shields.io/badge/Ruby-3.1.2-CC342D?logo=ruby&logoColor=red&color=green'>  
<img src='https://img.shields.io/badge/Rails-7.0.2-CC342D?logo=rubyonrails&logoColor=white&color=green&style=flatsquare'>
-->
Para levantar a aplicação, rode o comando no terminal:
```
rails telegram:bot:poller
```
