# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    user = User.find_for_database_authentication(username: params[:user][:username])
    if user && user.valid_password?(params[:user][:password])
      sign_in(user)
      render json: {
        status: { code: 200, message: 'User signed in successfully', data: user }
      }, status: :ok
    else
      render json: {
        status: 401,
        message: 'Invalid username or password'
      }, status: :unauthorized
    end
  end

  private 

  def respond_with(resource, options={})
    render json: {
      status: { code: 200, message: "User Signed in succesfully", data: current_user }
    }, status: :ok
  end

  def respond_to_on_destroy
    jwt_payload = JWT.decode(request.headers['Authorization'].split( ' ' )[1], Rails.application.credentials.fetch(:secret_key_base)).first
    current_user = User.find(jwt_payload['sub'])
    if current_user
      render json: {
        status: 200,
        message: "Signed out Succesfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "User has no active session"
      }, status: :unauthorized
    end
  end
end
