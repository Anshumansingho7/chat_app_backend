class ChatroomsController < ApplicationController
  before_action :authenticate_user

  def index
    chatrooms = current_user.chatrooms.includes(:users)
  
    chatrooms_json = chatrooms.map do |chatroom|
      other_user = chatroom.users.find { |user| user.id != current_user.id }
      {
        chatroom_id: chatroom.id,
        other_user: {
          id: other_user.id,
          username: other_user.username,
          email: other_user.email
        }
      }
    end
  
    render json: chatrooms_json
  end
  
  def create
    other_user = User.find(params[:user_id])
  
    unless current_user == other_user
      existing_chatroom = Chatroom.joins(:users)
                                  .where(users: { id: [current_user.id, other_user.id] })
                                  .distinct
                                  .group('chatrooms.id')
                                  .having('COUNT(users.id) = 2')
                                  .first
  
      if existing_chatroom
        other_user = existing_chatroom.exclude_current_user(current_user).first
        render json: {
          chatroom_id: existing_chatroom.id,
          other_user: {
            id: other_user.id,
            username: other_user.username,
            email: other_user.email
          }
        }
      else
        chatroom = Chatroom.new()
  
        if chatroom.save
          chatroom.users << [current_user, other_user]
          render json: {
            chatroom_id: chatroom.id,
            other_user: {
              id: other_user.id,
              username: other_user.username,
              email: other_user.email
            }
          }, status: :created
        else
          render json: { errors: chatroom.errors.full_messages }, status: :unprocessable_entity
        end
      end
    else
      render json: { error: 'You cannot chat with yourself' }, status: :unprocessable_entity
    end
  end
  
  private

  def authenticate_user
    jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], Rails.application.credentials.fetch(:secret_key_base)).first
    current_user = User.find(jwt_payload['sub'])
    render json: { status: 401, message: "User has no active session" }, status: :unauthorized unless current_user
  end
end
