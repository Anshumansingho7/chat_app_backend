# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?
  respond_to :json

  private 

  # Permit additional parameters for sign up and account update
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  # Customize the response format for JSON
  def respond_with(resource, _options = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully' },
        data: resource
      }
    else
      render json: {
        status: { code: 422, message: 'User could not be created successfully.', errors: resource.errors.full_messages }
      }, status: :unprocessable_entity
    end
  end
end
