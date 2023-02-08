require 'rails_helper'

RSpec.describe PointsController, type: :request do
  describe "GET points" do
    it "gets the points page index" do
      get points_url
      expect(response).to be_successful
    end
  end
end
