class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
    
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  liquid_methods :email, :first_name, :last_name, :nickname
  
  has_many :user_con_profiles
  
  def profile_for(con)
    user_con_profiles.where(con: con).first
  end
end
