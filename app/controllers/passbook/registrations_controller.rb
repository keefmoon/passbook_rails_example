class Passbook::RegistrationsController < ApplicationController
  respond_to :json

  # Get the serial numbers for passes associated with a device.
  # This happens the first time a device communicates with our web service.
  # Additionally, when a device gets a push notification, it asks our
  # web service for the serial numbers of passes that have changed since
  # a given update tag (timestamp).
  def index
    @passes = Passbook::Pass.where(pass_type_identifier: params[:pass_type_identifier])
    head :not_found and return if @passes.nil?

    @passes = @passes.where('updated_at > :passes_updated_since', {passes_updated_since: params[:passesUpdatedSince]}) if params[:passesUpdatedSince]

    @updated_at = []
    @serial_numbers = []

    # FIXME: Use ActiveRecord relationship instead of looping over each pass.
    @passes.each do |pass|
      if pass.registrations.where(device_library_identifier: params[:device_library_identifier]).count > 0
        @updated_at << pass[:updated_at]
        @serial_numbers << pass[:serial_number]
      end
    end

    if @serial_numbers.any?
      respond_with({lastUpdated: @updated_at.max, serialNumbers: @serial_numbers})
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
