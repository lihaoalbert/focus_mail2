class UserObserver < ActiveRecord::Observer
  observe :user
  def after_create(item)
    if item.email.split("@")[0].downcase == "admin" then
      create_useradmin(item.id, 1)
    else
      create_useradmin(item.id, 0)
    end
  end
  
  def create_useradmin(user_id, type_user)
    asset_type = %w{ Templates Campaigns Reports Lists Supers }
    asset_type.each do |assettype|
      Useradmin.create({
        :type_user => type_user,
        :asset_id => user_id,
        :asset_type => assettype
      })
    end
  end
end