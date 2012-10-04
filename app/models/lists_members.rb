class ListsMembers < ActiveRecord::Base
  attr_accessible :list_id, :member_id, :week_number
end
