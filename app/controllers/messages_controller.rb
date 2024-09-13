class MessagesController < ApplicationController
  before_action :authenticate_user!

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

  def message_params
    params.require(:message).permit(:content)
  end
end
