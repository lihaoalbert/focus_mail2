class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!, :user_right, :user_permission
  def user_right
    if user_signed_in?
      #puts useradmin.user_id
      ctrlweb = params[:controller].downcase
      useradmin  = Useradmin.where("asset_id = #{current_user.id} and asset_type = '#{ctrlweb.capitalize}'").first
      case ctrlweb
      when "templates"
        if useradmin.type_user != 1 then
          redirect_to :controller => 'home'
        end
      when "campaigns"
        if useradmin.type_user != 1 then
          redirect_to :controller => 'home'
        end
      when "reports"
        if useradmin.type_user != 1 then
          redirect_to :controller => 'home'
        end
      when "lists"
        if useradmin.type_user != 1 then
          redirect_to :controller => 'home'
        end
      end
    end
  end
  
  def user_permission
    if user_signed_in?
      useradmin  = Useradmin.where("asset_id = #{current_user.id} and asset_type = 'Supers'").first
      if useradmin.type_user == 1 || current_user.email.split("@")[0].downcase == "admin" then
        @super = 1
      else
        @super = 0
      end
    end
  end
  def user_action_log(assetid,assettype,actionname)
    assetid = assetid
    assettype = assettype
    actionname = actionname
    userid = current_user.id
    FocusMail::ClickLog.save_log(assetid, assettype, actionname, userid)
  end
end
