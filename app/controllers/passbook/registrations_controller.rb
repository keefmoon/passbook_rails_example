class Passbook::RegistrationsController < ApplicationController
  respond_to :json

  # Get the serial numbers for passes associated with a device.
  def index
    @pass = Passbook::Pass.where(pass_type_identifier: params[:pass_type_identifier]).first
    head :not_found and return if @pass.nil?

    @registrations = @pass.registrations.where(device_library_identifier: params[:device_library_identifier])
    @registrations = @registrations.where("updated_at >= :passes_updated_since", {passes_updated_since: params[:passes_updated_since]}) if params[:passes_updated_since]

    if @registrations.any?
      respond_with({lastUpdated: @registrations.maximum(:updated_at), serialNumbers: @registrations.collect(&:pass).collect(&:serial_number)})
    else
      head :no_content
    end
  end

  # Register a device to receive push notifications for a pass.
  def create
    @pass = Passbook::Pass.where(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
    head :not_found and return if @pass.nil?
    head :unauthorized and return if request.env['HTTP_AUTHORIZATION'] != "ApplePass #{@pass.authentication_token}"

    @registration = @pass.registrations.first_or_initialize(device_library_identifier: params[:device_library_identifier])
    @registration.push_token = params[:pushToken]

    status = @registration.new_record? ? :created : :ok

    @registration.save

    head status
  end

  # Unregister a device so it no longer receives push notifications for a pass.
  def destroy
    @pass = Passbook::Pass.where(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
    head :not_found and return if @pass.nil?
    head :unauthorized and return if request.env['HTTP_AUTHORIZATION'] != "ApplePass #{@pass.authentication_token}"

    @registration = @pass.registrations.where(device_library_identifier: params[:device_library_identifier]).first
    head :not_found and return if @registration.nil?

    @registration.destroy

    head :ok
  end
end
