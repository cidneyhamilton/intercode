class Room < ActiveRecord::Base
  belongs_to :convention
  has_and_belongs_to_many :runs
end
