require 'rails_helper'

RSpec.describe Units::SiController, type: :controller do
  describe "GET #index" do
    context "when given no units" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "returns an object with multiplication_factor and unit_name keys" do
        get :index
        parsed_response = JSON.parse(response.body)

        expect(parsed_response["unit_name"]).to eq("")
        expect(parsed_response["multiplication_factor"]).to eq(1.0)
      end
    end

    context "when given units" do
      it "returns http success" do
        get :index, params: {units: "ha*°"}
        expect(response).to have_http_status(:success)
      end

      it "returns an object with the correct multiplication_factor and unit_name values" do
        get :index, params: {units: "ha*°"}
        parsed_response = JSON.parse(response.body)

        expect(parsed_response["unit_name"]).to eq("m^2*rad")
        expect(parsed_response["multiplication_factor"]).to eq(174.53292519943295)
      end
    end
  end
end
