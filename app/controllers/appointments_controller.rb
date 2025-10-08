class AppointmentsController < ApplicationController
  # POST /appointments
  # Params: client_id, provider_id, starts_at, ends_at
  def create
    appointment = Appointment.new(appointment_params)
    if appointment.save
      render json: appointment, status: :created
    else
      render json: { error: appointment.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Record not found: #{e.message}" }, status: :not_found
  end

  # DELETE /appointments/:id
  # Bonus: cancel an appointment instead of deleting
  def destroy
    appointment = Appointment.find(params[:id])
    if appointment.update(status: :canceled, canceled_at: Time.zone.now)
      render json: appointment, status: :ok
    else
      render json: { error: appointment.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Record not found: #{e.message}" }, status: :not_found
  end

  private

  def appointment_params
    params.require(:appointment).permit(:client_id, :provider_id, :starts_at, :ends_at)
  end
end
