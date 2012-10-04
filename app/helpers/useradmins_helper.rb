module UseradminsHelper
  def user_permission(userid)
    @permissions = Useradmin.where("asset_id = #{userid}")
  end
end
