class ChatroomsController < ApplicationController
  before_action :authenticate_user

  def index
    # Preload chatrooms ke saath users aur messages to avoid N+1 queries
    chatrooms = current_user.chatrooms
                            .includes(:users, messages: :user) # Preloading users and messages with their users
                            .order(updated_at: :desc)
  
    # Map through chatrooms with preloaded data
    chatrooms_json = chatrooms.map do |chatroom|
      # Find other user without triggering an additional query
      other_user = chatroom.users.find { |user| user.id != current_user.id }
  
      # Use preloaded messages to calculate unread count, avoiding another query
      unread_count = chatroom.messages.select { |message| message.user_id == other_user.id && !message.read }.count
  
      {
        chatroom_id: chatroom.id,
        unread_count: unread_count,
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
  
    if current_user == other_user
      return
    end
  
    existing_chatroom = Chatroom.joins(:users)
                                .where(users: { id: [current_user.id, other_user.id] })
                                .distinct
                                .group('chatrooms.id')
                                .having('COUNT(users.id) = 2')
                                .first
  
    if existing_chatroom
      messages = existing_chatroom.messages.select(:id, :user_id, :chatroom_id, :content)
      other_user = existing_chatroom.exclude_current_user(current_user).first
      existing_chatroom.messages.where(user_id: other_user.id).update_all(read: true)
      render json: {
        chatroom: {
          chatroom_id: existing_chatroom.id,
          other_user: {
            id: other_user.id,
            username: other_user.username,
            email: other_user.email
          }
        },
        messages: messages.as_json(only: [:id, :user_id, :chatroom_id, :content])
      }
    else
      chatroom = Chatroom.new
  
      if chatroom.save
        chatroom.users << [current_user, other_user]
        render json: {
          chatroom: {
            chatroom_id: chatroom.id,
            other_user: {
              id: other_user.id,
              username: other_user.username,
              email: other_user.email
            }
          },
          messages: []
        }, status: :created
      else
        render json: { errors: "There is an issue please try again later" }, status: :unprocessable_entity
      end
    end
  end

  private

  def authenticate_user
    @current_user ||= get_current_user_from_token
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

  def current_user
    @current_user
  end
end
