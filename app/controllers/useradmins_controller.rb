class UseradminsController < ApplicationController
  # GET /Useradmins
  # GET /Useradmins.json
  def index
    @useradmins = Useradmin.find(:all, :select => "max(asset_id) as user_id, asset_id", :group => "asset_id")
    @useradmin = Useradmin.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @useradmins }
    end
  end

  # GET /Useradmins/1
  # GET /Useradmins/1.json
  def show
    redirect_to useradmin_members_path(params[:id])
  end

  # GET /Useradmins/new
  # GET /Useradmins/new.json
  def new
    @useradmin = Useradmin.new
    @users = User.all

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # GET /Useradmins/1/edit
  def edit
    @user = User.find(params[:id])
    @useradmin = Useradmin.where("asset_id = #{params[:id]}")

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /Useradmins
  # POST /Useradmins.json
  def create
    @useradmin = Useradmin.new(params[:useradmin])

    respond_to do |format|
      @useradmin.user_id = params[:user_id]
      if @useradmin.save
        format.html { redirect_to @useradmin, notice: 'Useradmin was successfully created.' }
        format.js
      else
        format.html { render action: "new" }
        format.js { render action: "new" }
      end
    end
  end

  # PUT /Useradmins/1
  # PUT /Useradmins/1.json
  def update
    @useradmin = Useradmin.find(params[:id])
    #
    respond_to do |format|
      if @useradmin.update_attributes(params[:useradmin])
        format.html { redirect_to @useradmin, notice: 'Useradmin was successfully updated.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js { render action: "edit" }
      end
    end
  end

  # DELETE /Useradmins/1
  # DELETE /Useradmins/1.json
  def destroy
    @useradmin = Useradmin.find(:all, :condiction => "asset_id = #{params[:id]}")
    @useradmin.destroy

    respond_to do |format|
      format.html { redirect_to useradmins_url }
      format.js
    end
  end
  
  def saveupdate
    user_id = params[:userid]
    templates = params[:templates]
    campaigns = params[:campaigns]
    reports = params[:reports]
    lists = params[:lists]
    supers = params[:supers]
    user_update(user_id, "Templates", templates)
    user_update(user_id, "Campaigns", campaigns)
    user_update(user_id, "Reports", reports)
    user_update(user_id, "Lists", lists)
    user_update(user_id, "Supers", supers)
    @user = User.find(user_id) 
    @useradmins = Useradmin.find(:all, :select => "max(asset_id) as user_id, asset_id", :group => "asset_id", :conditions => "asset_id = #{user_id}")
  end
  
  def user_update(asset_id, asset_type, type_user)
    useradmin = Useradmin.where("asset_id = #{asset_id} and asset_type = '#{asset_type}'").first
    useradmin.update_attributes(:type_user => type_user.to_i)
  end
end
