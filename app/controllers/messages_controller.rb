class MessagesController < ApplicationController
  before_action :authenticate_user

  def create
    chatroom = Chatroom.find(params[:chatroom_id])
    other_user = chatroom.exclude_current_user(current_user).first
    message = chatroom.messages.new(message_params.merge(user: current_user))

    if message.save
      broadcast_data = {
        id: message.id,
        content: message.content,
        user_id: current_user.id,
        other_user_id: other_user&.id,
        chatroom_id: chatroom.id
      }
      ActionCable.server.broadcast("chatroom_channel", broadcast_data)  
      render json: broadcast_data, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_user
    unless current_user
      render json: { status: 401, message: "User has no active session" }, status: :unauthorized
    end
  end

  def current_user
    @current_user ||= get_current_user_from_token
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

  def message_params
    params.require(:message).permit(:content)
  end
end
