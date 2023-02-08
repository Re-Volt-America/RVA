require 'rails_helper'

RSpec.describe DownloadsController, type: :request do
  describe "GET downloads" do
    it "gets the downloads page" do
      get downloads_url
      expect(response).to be_successful
    end
  end
end
