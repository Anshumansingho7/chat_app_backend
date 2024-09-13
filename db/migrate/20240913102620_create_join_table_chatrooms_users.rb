class CreateJoinTableChatroomsUsers < ActiveRecord::Migration[7.1]
  def change
    create_join_table :chatrooms, :users do |t|
      # t.index [:chatroom_id, :user_id]
      # t.index [:user_id, :chatroom_id]
    end
  end
end
