require 'rails_helper'

RSpec.describe RulesController, type: :request do
  describe "GET rules" do
    it "gets the rules page" do
      get rules_url
      expect(response).to be_successful
    end
  end

  describe "GET terms" do
    it "gets the terms of service page" do
      get terms_url
      expect(response).to be_successful
    end
  end

  describe "GET privacy" do
    it "gets the privacy page" do
      get privacy_url
      expect(response).to be_successful
    end
  end
end
