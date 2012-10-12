class Passbook::PassesController < ApplicationController
  respond_to :json

  # Get the latest version of a pass.
  def show
    @pass = Passbook::Pass.where(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
    render nothing: true, status: 401 and return if request.env['Authorization'] != "ApplePass #{@pass.authentication_token}"

    if @pass.nil?
      respond_with status: 404
    elsif stale?(last_modified: @pass.updated_at.utc)
      respond_with @pass
    else
      respond_with status: 304
    end
  end
end
