class Chatroom < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :messages

  def exclude_current_user(current_user)
    users.where.not(id: current_user.id)
  end
end
