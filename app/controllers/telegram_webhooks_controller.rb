class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include BotHelper

  def start!(*)
    respond_with :message, text: t('.content')
  end

  def help!(*)
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

  def callback_query(filtro)
    #binding.break
    if UF.keys.include?(filtro)
      respond_with :message, text: t('.estado', text: filtro)
      respond_with :message, text: nomes_deputados(deputados_por_estado(filtro))
    else
      respond_with :message, text: t('.partido', text: filtro)
      respond_with :message, text: nomes_deputados(deputados_por_partido(filtro))
    end
  end

  def inline_query(query, _offset)
    query = query.first(10) # it's just an example, don't use large queries.
    t_description = t('.description')
    t_content = t('.content')
    results = Array.new(5) do |i|
      {
        type: :article,
        title: "#{query}-#{i}",
        id: "#{query}-#{i}",
        description: "#{t_description} #{i}",
        input_message_content: {
          message_text: "#{t_content} #{i}",
        },
      }
    end
    answer_inline_query results
  end
  # As there is no chat id in such requests, we can not respond instantly.
  # So we just save the result_id, and it's available then with `/last_chosen_inline_result`.
  def chosen_inline_result(result_id, _query)
    session[:last_chosen_inline_result] = result_id
  end

  def last_chosen_inline_result!(*)
    result_id = session[:last_chosen_inline_result]
    if result_id
      respond_with :message, text: t('.selected', result_id: result_id)
    else
      respond_with :message, text: t('.prompt')
    end
  end

  def message(message)
    respond_with :message, text: t('.content', text: message['text'])
    respond_with :photo, photo: foto_deputado(message['text'])
  end

  def action_missing(action, *_args)
    if action_type == :command
      respond_with :message,
        text: t('telegram_webhooks.action_missing.command', command: action_options[:command])
    end
  end
end