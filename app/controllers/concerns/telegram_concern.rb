module TelegramConcern
  def estados_buttons
    buttons = []
    i = 0
    while i < 27 do
      buttons << [{text: UF.values[i], callback_data: UF.keys[i]},
                  {text: UF.values[i+1], callback_data: UF.keys[i+1]}]
      i = i + 2
    end
    buttons.last.pop
    buttons
  end

  def partidos_buttons
    siglas = lista_deputados.map{ |e| e['siglaPartido'] }.uniq
    tam = siglas.size
    buttons = []
    i = 0
    while i < tam do
      buttons << [{text: siglas[i], callback_data: siglas[i]},
                 {text: siglas[i+1], callback_data: siglas[i+1]}]
      i = i + 2
    end
    return buttons unless tam.odd?
    buttons.last.pop
    buttons
  end
end