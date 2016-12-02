require 'spec_helper'

describe AfterBranchDeleteService, services: true do
  let(:project) { create(:empty_project) }
  let(:user) { create(:user) }
  let(:service) { described_class.new(project, user) }

  describe '#execute' do
    it 'stops environments attached to branch' do
      expect(service).to receive(:stop_environments)

      service.execute('feature')
    end
  end
end
