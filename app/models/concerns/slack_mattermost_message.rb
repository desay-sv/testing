module SlackMattermostMessage
  def execute(data)
    return unless supported_events.include?(data[:object_kind])
    return unless webhook.present?

    object_kind = data[:object_kind]

    data = data.merge(
      project_url: project_url,
      project_name: project_name
    )

    # WebHook events often have an 'update' event that follows a 'open' or
    # 'close' action. Ignore update events for now to prevent duplicate
    # messages from arriving.

    message = get_message(object_kind, data)

    if message
      opt = {}

      opt[:channel]  = get_channel_field(object_kind).presence || channel || default_channel
      opt[:username] = username if username

      notifier = Slack::Notifier.new(webhook, opt)
      notifier.ping(message.pretext, attachments: message.attachments, fallback: message.fallback)

      true
    else
      false
    end
  end
end
