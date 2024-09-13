class User < ApplicationRecord
  searchkick
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
         
  has_and_belongs_to_many :chatrooms
  has_many :messages
  validates :username, presence: true, uniqueness: true

  def jwt_payload
    super
  end
end
