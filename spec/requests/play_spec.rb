require 'rails_helper'

RSpec.describe PlayController, type: :request do
  describe "GET play" do
    it "gets the play page index" do
      get play_url
      expect(response).to be_successful
    end
  end
end
