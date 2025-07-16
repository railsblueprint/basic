require 'rails_helper'

RSpec.describe 'Health endpoint', type: :request do
  describe 'GET /health' do
    it 'returns health status' do
      get '/health'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'returns JSON with health information' do
      get '/health'
      json = JSON.parse(response.body)
      
      expect(json).to include(
        'status' => 'ok',
        'version' => be_a(Hash),
        'git_revision' => be_a(String),
        'timestamp' => be_a(String)
      )
      
      # Should have at least basic version
      expect(json['version']).to have_key('basic')
      expect(json['version']['basic']).to match(/^\d+\.\d+\.\d+$/)
    end

    it 'does not require authentication' do
      get '/health'
      expect(response).to have_http_status(:ok)
    end
  end
end