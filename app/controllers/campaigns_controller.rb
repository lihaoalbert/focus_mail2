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

  def deliver
    @campaign = Campaign.find(params[:id])
    from_name = @campaign.from_name
    puts "from_name: " + from_name.to_s
    from_email = @campaign.from_email
    puts "from_email: " + from_email.to_s
    from = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    puts "from: " + from.to_s
    subject = @campaign.subject
    puts "subject: " + subject.to_s
    template_name = @campaign.template.file_name
    puts "template_name: " + template_name.to_s
    
    template_img_url = @campaign.template.img_url
    #bodyhtml = display_email(4,1)
    #puts bodyhtml.to_s
    
    @campaign.lists.collect(&:members).flatten.each do |member|
      to_email = member.email
      to_name = member.name
      
      #Resque.enqueue(Job,from, to_email, to_name, member.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url)
      email_with_template(from_email, from, to_email, to_name, member.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url)
    end
  end

  def template_entries
    @template = Template.find(params[:t_id])
    # because sometime @campaign does not exist when it's a new one
    @campaign = Campaign.find_by_id(params[:c_id])
    respond_to do |format|
      format.js
    end
  end
  
  def email_with_template(hfrom, from, to_email, to_name, member_id, subject, campaign_id, template_id, img_url)
      #source = replace_email_source(campaign_id, member_id)
      bodyhtml = "<body>"
      bodyhtml << display_email(template_id,img_url,member_id,campaign_id)
      bodyhtml << %Q{<img src="http://#{request.host}:#{request.port}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
      bodyhtml << "</body>"
      
      mail = Mail.deliver do
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
      #file = File.open("/home/work/#{to_name}.eml","w")
      #strfile = Time.now().to_i.to_s + " 00\n" + "F" + hfrom + "\n" + "R" + to_email + "\n" + "E\n"
      #strfile << mail.to_s
      #file.print(strfile)
      #file.close
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
          source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
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
end
