module JsonHelpers
  def json_response
    @_json_response ||= JSON.parse(response.body)
  end

  def jsonapi_headers
    { "Content-Type" => "application/vnd.api+json" }
  end
end

RSpec.configure do |config|
  config.include JsonHelpers, type: :request
end
