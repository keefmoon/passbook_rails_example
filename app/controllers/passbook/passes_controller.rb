class Passbook::PassesController < ApplicationController
  respond_to :json

  # Get the latest version of a pass.
  def show
    @pass = Passbook::Pass.where(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
    head :not_found and return if @pass.nil?
    head :unauthorized and return if request.env['HTTP_AUTHORIZATION'] != "ApplePass #{@pass.authentication_token}"

    if stale?(last_modified: @pass.updated_at.utc)
      respond_with @pass
    else
      head :not_modified
    end
  end
end
