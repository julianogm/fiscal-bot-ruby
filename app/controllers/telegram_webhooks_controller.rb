class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramConcern
  include CamaraConcern

  def iniciar!(*)
    respond_with :message, text: t('.mensagem')
  end

  def ajuda!(*)
    respond_with :message, text: t('.mensagem')
  end

  def deputados!(*)
    respond_with :message, text: t('.mensagem'), reply_markup: {
      inline_keyboard: [
          [ {text: "Por Estado", callback_data: "estados"},
            {text: "Por Partido", callback_data: "partidos"}, ]
      ]
    }
  end

  def estados!(*)
    respond_with :message, text: t('.estados'), reply_markup: {
      inline_keyboard: estados_buttons
    }
  end

  def partidos!(*)
    respond_with :message, text: t('.partidos'), reply_markup: {
      inline_keyboard: partidos_buttons
    }
  end

  def deputado!(n1 = nil, n2 = nil, n3 = nil, n4 = nil, n5 = nil, n6 = nil)
    nome_deputado = [n1,n2,n3,n4,n5,n6].join(' ').strip
    nome_deputado.downcase!

    if nome_deputado.empty?
      respond_with :message, text: t('.nome_em_falta')
      return
    end

    if nome_deputado.size < 3
      respond_with :message, text: t('.nome_curto')
      return
    end

    lista = deputados_por_nome(nome_deputado)
    deputado = nil
    deputado = lista.first if lista.size==1

    if lista.empty?
      respond_with :message, text: t('.invalido')
    elsif deputado.nil?
      respond_with :message, text: nomes_deputados(lista)
    else
      respond_with :photo, photo: deputado['urlFoto']
      respond_with :message, text: dados_deputado(deputado)
    end
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

  def action_missing(action, *_args)
    if action_type == :command
      respond_with :message,
        text: t('telegram_webhooks.comando_invalido.mensagem', command: action_options[:command])
    end
  end
end