class List < ActiveRecord::Base
  attr_accessible :name
  #has_many :members
  has_and_belongs_to_many :members
end
