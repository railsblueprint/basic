describe ErrorsController do
  render_views

  describe "GET #show error 404" do
    it "renders not found page", :aggregate_failures do
      get :show, params: { code: "404" }
      expect(response).to have_http_status(:not_found)
      expect(response.body).to match(/The page you were looking for doesn't exist./)
      expect(response.body).to match(/<!-- ROLLBAR ERROR -->/)
    end
  end

  describe "GET #show error 422" do
    it "renders not found page", :aggregate_failures do
      get :show, params: { code: "422" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to match(/The change you wanted was rejected/)
    end
  end

  describe "GET #show error 500" do
    it "renders not found page", :aggregate_failures do
      get :show, params: { code: "500" }
      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to match(/We're sorry, but something went wrong/)
      expect(response.body).to match(/<!-- ROLLBAR ERROR -->/)
    end
  end
end
