class Passbook::LogsController < ApplicationController
  respond_to :json

  # Add messages to the web server log.
  def create
    params[:logs].each { |message| Passbook::Log.create(message: message) }
    head :ok
  end
end
