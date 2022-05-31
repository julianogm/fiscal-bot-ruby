class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramConcern
  include CamaraConcern

  def iniciar!(*)
    respond_with :message, text: t('.content')
  end

  def ajuda!(*)
    respond_with :message, text: t('.content')
  end

  def keyboard!(value = nil, *)
    if value
      respond_with :message, text: t('.selected', value: value)
    else
      save_context :keyboard!
      respond_with :message, text: t('.prompt'), reply_markup: {
        keyboard: [t('.buttons')],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true,
      }
    end
  end

  def deputados!(*)
    respond_with :message, text: "Escolha um Filtro", reply_markup: {
      inline_keyboard: [
          [{text: "Por Estado", callback_data: "estados"},
           {text: "Por Partido", callback_data: "partidos"}]
      ]
    }
  end

  def estados!(*)
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: estados_buttons
    }
  end

  def partidos!(*)
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: partidos_buttons
    }
  end

  def deputado!(n1, n2 = nil, n3 = nil, n4 = nil, n5 = nil)
    nome_deputado = [n1,n2,n3,n4,n5].join(' ').strip
    #if(nomes_deputados.include?(message['text'])) do
      respond_with :photo, photo: foto_deputado(nome_deputado)
      respond_with :message, text: dados_deputado(nome_deputado)
  end

  def callback_query(filtro)
    if UF.keys.include?(filtro)
      respond_with :message, text: t('.estado', text: UF[filtro])
      respond_with :message, text: nomes_deputados(deputados_por_estado(filtro))
    elsif ["estados","partidos"].include?(filtro)
      partidos! if filtro == "partidos"
      estados! if filtro == "estados"
    else
      respond_with :message, text: t('.partido', text: filtro)
      respond_with :message, text: nomes_deputados(deputados_por_partido(filtro))
    end
  end

  def message(message)
    #if(nomes_deputados.include?(message)) do
    respond_with :photo, photo: foto_deputado(message['text'])
    respond_with :message, text: dados_deputado(message['text'])
  end

  def action_missing(action, *_args)
    if action_type == :command
      respond_with :message,
        text: t('telegram_webhooks.action_missing.command', command: action_options[:command])
    end
  end
end