class ErrorsController < ApplicationController
  def show
    body = File.read("public/#{status_code}.html").html_safe # rubocop:disable Rails/OutputSafety
    render html: body, status: status_code
  end

  protected

  def status_code
    params[:code] || 500
  end
end
