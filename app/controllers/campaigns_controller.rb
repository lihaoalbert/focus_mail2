#encoding : utf-8
require 'resque'
require 'mail'
class CampaignsController < ApplicationController
  # GET /campaigns
  # GET /campaigns.json
  def index
    @campaigns = Campaign.all
    @campaign = Campaign.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @campaigns }
    end
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
    @campaign = Campaign.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @campaign }
    end
  end

  def new
    @campaign = Campaign.new

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  def edit
    @campaign = Campaign.find(params[:id])
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    
    if params[:campaign][:from_time] != "" then
      strdate = params[:datepicker].to_s
      strhour = params[:selecthour].to_i
      strminute = params[:selectminute].to_i
      strsecond = params[:selectsecond].to_i
      if strdate != nil && strdate != "" then
        datearray = strdate.split("-")
        stryear = datearray[0].to_i
        strmonth = datearray[1].to_i
        strday = datearray[2].to_i
        strdatetime = Time.new(stryear,strmonth,strday,strhour,strminute,strsecond, "+08:00")
        Resque.enqueue_at(strdatetime, Sendmail_Job, params[:id], current_user.id)
      end
    end

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to @campaign, notice: 'Campaign was successfully created.' }
        format.js
      else
        format.html { render action: "new" }
        format.js { render action: "new" }
      end
    end
  end

  def update
    @campaign = Campaign.find(params[:id])
    if params[:campaign][:from_time] != "" then
      if @campaign.from_time != nil && @campaign.from_time != "" then
        Resque.remove_delayed(params[:id], current_user.id)
      end
      strdate = params[:datepicker].to_s
      strhour = params[:selecthour].to_i
      strminute = params[:selectminute].to_i
      strsecond = params[:selectsecond].to_i
      if strdate != nil && strdate != "" then
        datearray = strdate.split("-")
        stryear = datearray[0].to_i
        strmonth = datearray[1].to_i
        strday = datearray[2].to_i
        strdatetime = Time.new(stryear,strmonth,strday,strhour,strminute,strsecond, "+08:00")
        Resque.enqueue_at(strdatetime, Sendmail_Job, params[:id], current_user.id)
      end
    end
    
    respond_to do |format|
      if @campaign.update_attributes(params[:campaign])
        format.html { redirect_to @campaign, notice: 'Campaign was successfully updated.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js { render action: "edit" }
      end
    end
  end

  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy

    respond_to do |format|
      format.html { redirect_to campaigns_url }
      format.js
    end
  end
  
  def mailtest
    @campaign = Campaign.find(params[:id])
    from_name = @campaign.from_name
    from_email = @campaign.from_email
    from = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    subject = @campaign.subject
    template_name = @campaign.template.file_name
    to_email = params[:emailname]
    to_name = ""
    template_img_url = @campaign.template.img_url
    email_one_template(from_email, from, to_email, to_name, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,current_user.id)
  end

  def deliver
    Resque.enqueue(Sendmail_Job, params[:id], current_user.id)
    #@campaign = Campaign.find(params[:id])
    #from_name = @campaign.from_name
    #puts "from_name: " + from_name.to_s
    #from_email = @campaign.from_email
    #puts "from_email: " + from_email.to_s
    #from = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    #puts "from: " + from.to_s
    #subject = @campaign.subject
    #puts "subject: " + subject.to_s
    #template_name = @campaign.template.file_name
    #puts "template_name: " + template_name.to_s
    #
    #template_img_url = @campaign.template.img_url
    ##bodyhtml = display_email(4,1)
    ##puts bodyhtml.to_s
    #memberarray = Array.new
    #puts "===================================================="
    #@campaign.lists.collect(&:members).flatten.each do |member|
    #  #to_email = member.email
    #  #to_name = member.name
    #  memberarray.push(member.id)
    #  #Resque.enqueue(Job,from, to_email, to_name, member.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url)
    #  #email_with_template(from_email, from, to_email, to_name, member.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url)
    #end
    #if memberarray.length > memberarray.uniq.length then
    #  @test = "重复"
    #else
    #  @test = "不重复"
    #end
    #members = Member.find(memberarray.uniq)
    #puts current_user.id
    #if members.count > 0 then
    #  if members.count == 1 then
    #    to_email = member.email
    #    to_name = member.name
    #    email_with_template(from_email, from, to_email, to_name, members.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,current_user.id)
    #  else
    #    members.each do |m|
    #      to_email = m.email
    #      to_name = m.name
    #      email_with_template(from_email, from, to_email, to_name, m.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,current_user.id)
    #    end
    #  end
    #end
  end

  def template_entries
    @template = Template.find(params[:t_id])
    # because sometime @campaign does not exist when it's a new one
    @campaign = Campaign.find_by_id(params[:c_id])
    respond_to do |format|
      format.js
    end
  end
  
  def email_one_template(hfrom, from, to_email, to_name, subject, campaign_id, template_id, img_url,user_id)
    puts "+++++++++++++++++++++++++++++++"
    puts to_name.present?
    puts "+++++++++++++++++++++++++++++++"
    readfile = YAML.load_file('config/readfile.yml')
    bodyhtml = "<body>"
      bodyhtml << display_one_email(template_id,img_url,campaign_id)
      bodyhtml << "</body>"
      
      mail = Mail.new do
        to      to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email #'yy_lfy@126.com'
        from    from #'eric yue <eric_yue@intfocus.com>'
        reply_to readfile["reply"].to_s
        subject subject #'First multipart email sent with Mail大口大口的'
      
        #text_part do
         # body 'This is plain text'
        #end
      
        html_part do
          content_type 'text/html; charset=UTF-8'
          body bodyhtml.to_s
        end
        #add_file '/home/work/vicm.png'
      end
      #mail.attachments['vicm.png'] = {:mime_type => 'application/x-gzip',:content_id => abc,:content => File.read('/home/work/vicm.png')}
      #puts mail.to_s
      filename = to_name + Time.now().to_i.to_s
      sendmail = readfile["sendmail"].to_s + "#{filename}.eml"
      file = File.open(sendmail,"w")
      strfile = Time.now().to_i.to_s + " 00\n" + "F" + hfrom + "\n" + "R" + to_email + "\n" + "E\n"
      strfile << mail.to_s
      file.print(strfile)
      file.close
      create_email_log(template_id,hfrom,to_email,subject,user_id)
  end
  
  def email_with_template(hfrom, from, to_email, to_name, member_id, subject, campaign_id, template_id, img_url,user_id)
      #source = replace_email_source(campaign_id, member_id)
      bodyhtml = "<body>"
      bodyhtml << display_email(template_id,img_url,member_id,campaign_id)
      bodyhtml << %Q{<img src="http://#{request.host}:#{request.port}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
      bodyhtml << "</body>"
      
      mail = Mail.new do
        to      to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email #'yy_lfy@126.com'
        from    from #'eric yue <eric_yue@intfocus.com>'
        subject subject #'First multipart email sent with Mail大口大口的'
      
        #text_part do
         # body 'This is plain text'
        #end
      
        html_part do
          content_type 'text/html; charset=UTF-8'
          body bodyhtml.to_s
        end
        #add_file '/home/work/vicm.png'
      end
      #mail.attachments['vicm.png'] = {:mime_type => 'application/x-gzip',:content_id => abc,:content => File.read('/home/work/vicm.png')}
      #puts mail.to_s
      filename = to_name + Time.now().to_f.to_s
      readfile = YAML.load_file('config/readfile.yml')
      sendmail = readfile["sendmail"].to_s + "#{filename}.eml"
      file = File.open(sendmail,"w")
      strfile = Time.now().to_i.to_s + " 00\n" + "F" + hfrom + "\n" + "R" + to_email + "\n" + "E\n"
      strfile << mail.to_s
      file.print(strfile)
      file.close
      create_email_log(template_id,hfrom,to_email,subject,user_id)
  end
  
  def display_one_email(template_id,img_url,campaign_id)
    template = Template.find(template_id)
    if template.zip_url != nil then
      images = "/files/" + template.zip_url.to_s.split(".")[0] + "/images/"
    else
      images = "/images/"
    end
    entries = Entry.find_all_by_template_id(template_id)
    source = IO.readlines(Rails.root.join('lib/emails', "#{template.file_name}.html.erb")).join("").strip
    source = source.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
    source = source.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
    entries.each do |e|
      if e.name.include? "img" then
        if img_url == 1 then
          source = source.gsub(/\$\|#{e.name}\|\$/, "cid:" + e.default_value.to_s)
        else
          if(e.default_value.to_s=~/http:\/\/([\w-]+\.)+[\w-]+(\/[\w-]*)?.*/) != nil then
            source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
          else
            source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{request.host}:#{request.port}#{images}" + e.default_value)
          end
        end
        
      else
        v = e.default_value
        if %r{^http://(.*)}.match(e.default_value)
          link = Link.where(:url => v).first_or_create
          v = link.url
          source = source.gsub(/\$\|#{e.name}\|\$/, v)
        else
          source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
        end
      end
    end
    return source.lstrip
  end
  
  def display_email(template_id,img_url,member_id,campaign_id)
    template = Template.find(template_id)
    entries = Entry.find_all_by_template_id(template_id)
    source = IO.readlines(Rails.root.join('lib/emails', "#{template.file_name}.html.erb")).join("").strip
    source = source.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
    source = source.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
    entries.each do |e|
      if e.name.include? "img" then
        if img_url == 1 then
          source = source.gsub(/\$\|#{e.name}\|\$/, "cid:" + e.default_value.to_s)
        else
          source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{request.host}:#{request.port}/images/" + e.default_value)
        end
        
      else
        v = e.default_value
        if %r{^http://(.*)}.match(e.default_value)
          link = Link.where(:url => v).first_or_create
          v = "http://#{request.host}:#{request.port}/click?u=#{member_id}&c=#{campaign_id}&l=#{link.id}"
          source = source.gsub(/\$\|#{e.name}\|\$/, v)
        else
          source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
        end
      end
    end
    return source.lstrip
  end
  
  def create_email_log(template_id,hfrom,to_email,subject,user_id)
    CemailLog.create({
      :template_id => template_id,
      :from_email => hfrom,
      :to_eamil => to_email,
      :subject => subject,
      :user_id => user_id
    })
  end
end
