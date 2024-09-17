class SearchController < ApplicationController
  before_action :authenticate_user

  def search
    if params[:search].present?
      users = User.search(params[:search], fields: [:username])
      render json: users.results
    else
      render json: { error: "Search term is missing" }, status: :bad_request
    end
  end 

  def current_user
    user = get_current_user_from_token
    if user
      render json: {
        status: 200,
        user: user
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "User has no active session"
      }, status: :unauthorized
    end
  end

  private

  def authenticate_user
    user = get_current_user_from_token
    render json: { status: 401, message: "User has no active session" }, status: :unauthorized unless user
  end

  def get_current_user_from_token
    token = request.headers['Authorization']&.split(' ')&.last
    return nil unless token

    begin
      jwt_payload = JWT.decode(token, Rails.application.credentials.fetch(:secret_key_base)).first
      User.find_by(id: jwt_payload['sub'])
    rescue JWT::DecodeError
      nil
    end
  end
end
