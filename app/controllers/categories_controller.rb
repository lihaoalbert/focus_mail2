#encoding:utf-8
class CategoriesController < ApplicationController
  # GET /categories
  # GET /categories.json
  def index
    user_id = current_user.id
    userids = [6,7,8,9,10,12,13]
    if userids.index(user_id) != nil then
      @lists = List.order("created_at desc").paginate(:page => params[:page], :per_page => 5)
      @list = List.new
      @category = List.new
      @category.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    else
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller).join(",")
      if orglist.length == 0 then
        @lists = List.paginate(:page => params[:page], :per_page => 5, :conditions => "1=2", :order => "created_at desc")
      else
        @lists = List.paginate(:page => params[:page], :per_page => 5, :conditions => "id in (#{orglist})", :order => "created_at desc")
      end
      @category = List.new
      @category.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    end
    @memberorg = MemberOrg.paginate(:page => params[:page], :per_page => 20)
    user_action_log(0,params[:controller],"index")
    WillPaginate::ViewHelpers.pagination_options[:previous_label] = '上一页'
    WillPaginate::ViewHelpers.pagination_options[:next_label] = '下一页' 

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @memberorg }
    end
  end
  
  def new
    #@list = List.new
    user_id = current_user.id
    @category = List.new
    @category.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    user_action_log(0,params[:controller],"new")

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end
  
  def edit
    @category = List.find(params[:id])
    user_action_log(params[:id],params[:controller],"edit")

    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def create
    List.create({
      :name => params[:name],
      :org_id => params[:org_id]
    })
  end
  
  def update
    @lupdate = List.update(params[:id],{
      :name => params[:name]
    })
    session[:list_id] = @lupdate.id
  end
  
  def destroy
    @list = List.find(params[:id])
    @list.destroy
    user_action_log(params[:id],params[:controller],"delete")
  end
  
end
