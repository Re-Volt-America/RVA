require 'rails_helper'

RSpec.describe AssetsController, :type => :request do
  describe 'GET logos' do
    it 'gets the logos page' do
      get logos_url
      expect(response).to be_successful
    end
  end
end
