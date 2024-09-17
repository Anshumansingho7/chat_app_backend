class MessagesController < ApplicationController
  before_action :authenticate_user

  def create
    chatroom = Chatroom.find(params[:chatroom_id])
    message = chatroom.messages.new(message_params.merge(user: current_user))
    
    if message.save
      render json: message, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_user
    jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], Rails.application.credentials.fetch(:secret_key_base)).first
    current_user = User.find(jwt_payload['sub'])
    render json: { status: 401, message: "User has no active session" }, status: :unauthorized unless current_user
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
