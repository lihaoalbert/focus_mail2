require 'resque'
require 'mail'
class Sendmail_Job
  @queue = "job_test1"
  def self.perform(id,user_id)
    @campaign = Campaign.find(id.to_i)
    from_name = @campaign.from_name
    from_email = @campaign.from_email
    if from_email != "" && from_email != nil then
      from_email_array = from_email.split("@")
      from_email = from_email_array[0] + "_#{@campaign.id}_0@" + from_email_array[1]
    end
    from = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    subject = @campaign.subject
    template_name = @campaign.template.file_name
    
    template_img_url = @campaign.template.img_url
    
    memberarray = Array.new
    @campaign.lists.collect(&:members).flatten.each do |member|
      memberarray.push(member.id)
    end
    members = Member.find(memberarray.uniq)
    if members.count > 0 then
      if members.count == 1 then
        to_email = member.email
        to_name = member.name
        Sendmail_Job.new.email_with_template_job(from_email, from, to_email, to_name, members.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,user_id)
      else
        members.each do |m|
          to_email = m.email
          to_name = m.name
          Sendmail_Job.new.email_with_template_job(from_email, from, to_email, to_name, m.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,user_id)
        end
      end
    end
  end
  
  def email_with_template_job(hfrom, from, to_email, to_name, member_id, subject, campaign_id, template_id, img_url,user_id)
    readfile = YAML.load_file('config/readfile.yml')
    readip = readfile["sendip"]
    readport = readfile["sendport"]
    bodyhtml = "<body>"
    bodyhtml << Sendmail_Job.new.display_email_job(template_id,img_url,member_id,campaign_id)
    bodyhtml << %Q{<img src="http://#{readip}:#{readport}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
    bodyhtml << "</body>"
    
    mail = Mail.new do
      to      to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email
      from    from
      reply_to "replyto_" + campaign_id.to_s + "_" + user_id.to_s + readfile["reply"].to_s
      subject subject
    
      html_part do
        content_type 'text/html; charset=UTF-8'
        body bodyhtml.to_s
      end
    end
    filename = to_name + Time.now().to_f.to_s
    sendmail = readfile["sendmail"].to_s + "#{filename}.eml"
    file = File.open(sendmail,"w")
    strfile = Time.now().to_i.to_s + " 00\r\n" + "F" + hfrom + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
    strfile << mail.to_s
    file.print(strfile.gsub!(/\r\n/, "\n"))
    file.close
    Sendmail_Job.new.create_email_log(template_id,hfrom,to_email,subject,user_id,campaign_id)
  end
  
  def display_email_job(template_id,img_url,member_id,campaign_id)
    readfile = YAML.load_file('config/readfile.yml')
    readip = readfile["sendip"]
    readport = readfile["sendport"]
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
            source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{readip}:#{readport}#{images}" + e.default_value)
          end
        end
        
      else
        v = e.default_value
        if %r{^http://(.*)}.match(e.default_value)
          link = Link.where(:url => v).first_or_create
          v = "http://#{readip}:#{readport}/click?u=#{member_id}&c=#{campaign_id}&l=#{link.id}"
          source = source.gsub(/\$\|#{e.name}\|\$/, v)
        else
          source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
        end
      end
    end
    return source.lstrip.to_s
  end
  
  def create_email_log(template_id,hfrom,to_email,subject,user_id,campaign_id)
    CemailLog.create({
      :campaign_id => campaign_id,
      :template_id => template_id,
      :from_email => hfrom,
      :to_eamil => to_email,
      :subject => subject,
      :user_id => user_id
    })
  end
end
