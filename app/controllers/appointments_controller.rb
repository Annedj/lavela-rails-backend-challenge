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
    raise NotImplementedError, "Implement appointment cancelation endpoint"
  end

  private

  def appointment_params
    params.require(:appointment).permit(:client_id, :provider_id, :starts_at, :ends_at)
  end
end
