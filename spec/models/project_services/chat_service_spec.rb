require 'spec_helper'

describe ChatService, models: true do
  describe "Associations" do
    it { is_expected.to have_many :chat_names }
  end
end
