class Passbook::LogsController < ApplicationController
  respond_to :json

  def create
    params[:logs].each { |message| Passbook::Log.create(message: message) }
    render nothing: true, status: 200
  end
end
