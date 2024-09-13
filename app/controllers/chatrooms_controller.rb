class ChatroomsController < ApplicationController
  before_action :authenticate_user!

  def index
    chatrooms = current_user.chatrooms
    render json: chatrooms, include: [:users, :messages]  
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
        render json: existing_chatroom.as_json(include: [:users, :messages])
      else
        chatroom = Chatroom.new()
    
        if chatroom.save
          chatroom.users << [current_user, other_user]
          render json: chatroom.as_json(include: [:users, :messages]), status: :created
        else
          render json: { errors: chatroom.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end  

  private

  def chatroom_params
    params.require(:chatroom).permit(:name)
  end
end
