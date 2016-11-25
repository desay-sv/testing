require 'spec_helper'
Dir[Rails.root.join("app/models/project_services/chat_message/*.rb")].each { |f| require f }

describe SlackService, models: true do
  it_behaves_like "slack or mattermost"
end
