class SearchController < ApplicationController
  before_action :authenticate_user

  def search
    if params[:search].present?
      query = {
        query: {
          bool: {
            should: [
              {
                multi_match: {
                  query: params[:search],
                  fields: ['username^3'],
                  fuzziness: 'AUTO',
                  operator: 'and',
                  prefix_length: 1
                }
              },
              {
                wildcard: {
                  username: {
                    value: "*#{params[:search].downcase}*", # Wildcard search
                    boost: 2.0
                  }
                }
              }
            ]
          }
        }
      }
  
      users = User.search(query).records
      formatted_users = users.map do |user|
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
      render json: { error: "Search term missing" }, status: :bad_request
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
