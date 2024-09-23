class SearchController < ApplicationController
  before_action :authenticate_user

  def search
    if params[:search].present?
      users = User.search(params[:search], fields: [:username])
      formatted_users = users.results.map do |user|
        {
          chatroom_id: nil,
          other_user: {
            id: user.id,
            username: user.username,
            email: user.email
          }
        }
      end
      render json: formatted_users
    else
    end
  end  


  private

  def authenticate_user
    user = get_current_user_from_token
    unless current_user
      render json: {
        status: 401,
        message: "User has no active session"
      }, status: :unauthorized    
    end  
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
