require 'rails_helper'

RSpec.describe Units::SiController, type: :controller do
  describe "GET #index" do
    before(:each) do
      get :index, params: {units: "ha*°"}
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns an object with multiplication_factor and unit_name keys" do
      parsed_response = JSON.parse(response.body)

      expect(parsed_response["unit_name"]).to eq("m^2*rad")
      expect(parsed_response["multiplication_factor"]).to eq(174.53292519943295)
    end
  end
end
