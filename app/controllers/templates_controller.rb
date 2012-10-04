#encoding : utf-8
class TemplatesController < ApplicationController

  def index
    @templates = Template.all
    @template = Template.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @templates }
    end
  end

  def show
    @template = Template.find(params[:id])
    respond_to do |format|
      format.html { redirect_to :action => "index" } # show.html.erb
      format.json { render json: @template }
    end
  end

  def new
    @template = Template.new

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @template = Template.find(params[:id])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    if_succ = false
    path = ""
     #如果说什么也没有接收到
    if request.get?
      @system_uploadfile = SystemUploadfile.new
      flash.now[:notice] = "文件上传失败"
      render :action => "new"
    else
      @template = Template.new(params[:template])
       #获取上传的文件
      uploaded_file = params[:template][:zip_url]
      if uploaded_file != "" && uploaded_file != nil then
        if_succ,filepath,path = upload_file(uploaded_file,Template::File_extname,Template::File_target)
      end
  
      respond_to do |format|
        if if_succ then
          @template.set_file_values(filepath, uploaded_file.original_filename)
        end
        if @template.save
          format.html { redirect_to @template, notice: 'Template was successfully created.' }
          format.js
        else
          format.html { render action: "new" }
          format.js { render action: "new" }
        end
      end
    end
  end

  def update
    @template = Template.find(params[:id])

    respond_to do |format|
      if @template.update_attributes(params[:template])
        format.html { redirect_to @template, notice: 'Template was successfully updated.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js { render action: "edit" }
      end
    end
  end

  def destroy
    @template = Template.find(params[:id])
    @template.destroy

    respond_to do |format|
      format.html { redirect_to templates_url }
      format.js
    end
  end
  
  def saveimgurl
    imgurl = params[:iu]
    if imgurl != "" && imgurl != nil then
      imgurls = imgurl.split("_")
      puts imgurls[0]
      puts imgurls[1]
      Template.update(imgurls[0], :img_url => imgurls[1])
    end
  end
  
  def upload_file(file,extname,target_dir)
    if file.nil? || file.original_filename.empty?
      return false,"空文件或者文件名错误"
    else
      timenow = Time.now
      filename = file.original_filename  #file的名字
      mvfilename = (0..16).to_a.map{|a| rand(16).to_s(16)}.join #产生一个十六进制的字符串
      fileloadname = timenow.strftime("%d%H%M%S")+mvfilename+".zip" #保存在文件夹下面的上传文件的名称

      if extname.include?(File.extname(filename).downcase)
        #创建目录
        #首先获得当前项目所在的目录+文件夹所在的目录
        path = Rails.root.join(target_dir,timenow.year.to_s,timenow.month.to_s)
        #生成目录
        FileUtils.makedirs(path)
        File.open(File.join(path,fileloadname),"wb") do |f|
          f.write(file.read)
          return true,File.join(timenow.year.to_s,timenow.month.to_s,fileloadname),path
        end
      else
        return false,"必须是#{extname}类型的文件"
      end
    end
  end
end
