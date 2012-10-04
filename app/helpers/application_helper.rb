module ApplicationHelper
  def full_title(page_title)
    base_title = "Focus Mail"
    if page_title.empty?
      base_title
    else
      %Q{#{base_title} | #{page_title}}
    end
  end

  def replace_email_source(campaign_id, member_id)
    campaign = Campaign.find(campaign_id)
    source = IO.readlines(Rails.root.join('lib/emails', "#{campaign.template.file_name}.html.erb")).join("").strip

    # replace all campaign_entries
    entries = campaign.valid_entries
    entries.each do |e|
      v = e.value
      # replace all links with virtual url
      if %r{^http://(.*)}.match(e.value)
        # create a link
        link = Link.where(:url => v).first_or_create
        v = "http://#{request.host}:#{request.port}/click?u=#{member_id}&c=#{campaign.id}&l=#{link.id}"
      end
      
      source = source.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
      source = source.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
      if(v.to_s=~/http:\/\/([\w-]+\.)+[\w-]+(\/[\w-]*)?.*/) != nil then
        source = source.gsub(/\$\|#{e.entry.name}\|\$/, v)
      else
        source = source.gsub(/\$\|#{e.entry.name}\|\$/, "http://#{request.host}:#{request.port}/images/" + v)
      end
    end

    source
  end
  
  def display_email(template_id,img_url)
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
        source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
      end
    end
    return source.lstrip
  end

  def get_campaign_summery(campaign_id)
	@cam_summery = SendState.find(:last,
                     :select => "be_hits_number, be_hits_ratio, effective_operand_address, has_sent_number, open_number, open_ratio, reach_number, reach_ratio, send_ratio, total_address_number, campaign_id",
                     :conditions => ["send_states.campaign_id = ?", campaign_id])
    @campaign = Campaign.find(campaign_id);
  if @cam_summery != nil then
    @pie = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart({:plotBackgroundColor=>'null' , 
        :height => 100,
        :width => 100,
        :plotShadow => false})
      f.title({:text=> ''})
      f.plotOptions({:pie=>{
          :allowPointSelect=> true , 
          :cursor=> 'pointer' , 
          :dataLabels=>{
            :enabled=> false , 
            :color=> '#000000' , 
            :connectorColor=> '#000000'}}})
      f.series({:type=>'pie' , :name=> 'Browser share' , 
          :data=> [
        ['back hard', @cam_summery.effective_operand_address.to_i],
        ['back soft', @cam_summery.reach_number.to_i],
        ['Reached', @cam_summery.open_number.to_i],
        ['Account', @cam_summery.be_hits_number.to_i]
      ]})
      f.tooltip({:enabled => false })
    end
      
    @send_totle = @cam_summery.total_address_number#50000
    @send_reach = @cam_summery.reach_number#45000
    @back_hard = @cam_summery.reach_ratio#2100
    @back_soft = @cam_summery.open_ratio#1300
    @account_erro = @cam_summery.be_hits_ratio#1100
    @back_other = @cam_summery.effective_operand_address#500
   else
    @send_totle = 0
    @send_reach = 0
    @back_hard = 0
    @back_soft = 0
    @account_erro = 0
    @back_other = 0
    @pie = ''
   end
      
    @return = {:name => @campaign.subject,
      :id => @campaign.id,
      :send_totle => @send_totle,
      :pie => @pie,
      :send_reach => @send_reach,
      :back_hard => @back_hard,
      :back_soft => @back_soft,
      :account_erro => @account_erro
      }
    
  end
  
  def get_campaign_report_by_id(id)
    #@campaign_id = id
    #@campaign_name = Campaign.find(@campaign_id).name
    #总名单人数
    @total_members = CampaignList.find(:all,
                     :select => "count(distinct members.id) AS MemberCount",
                     :joins => "LEFT JOIN members ON campaign_lists.list_id = members.list_id",
                     :conditions => ["campaign_lists.campaign_id = ?", @campaign_id])[0].MemberCount
    #总打开人数       
    @total_tracks = Track.find(:all,
                     :select => "count(distinct tracks.member_id) AS MemberCount",
                     :conditions => ["tracks.campaign_id = ?", @campaign_id])[0].MemberCount
    #总点击人数
    @total_clickers = Click.find(:all,
                     :select => "count(distinct clicks.member_id) AS MemberCount",
                     :conditions => ["clicks.campaign_id = ?", @campaign_id])[0].MemberCount
    #总点击次数
    @total_clicks = Click.find(:all,
                     :select => "count(clicks.member_id) AS MemberCount",
                     :conditions => ["clicks.campaign_id = ?", @campaign_id])[0].MemberCount
    #总点击次数
    @cam_summery = SendState.find(:last,
                     :select => "be_hits_number, be_hits_ratio, effective_operand_address, has_sent_number, open_number, open_ratio, reach_number, reach_ratio, send_ratio, total_address_number, campaign_id",
                     :conditions => ["send_states.campaign_id = ?", @campaign_id])[0].MemberCount

attr_accessible                 
    @report_array = Array.new
    @report_array.push(@campaign_name,@total_members,@total_tracks,@total_clickers,@total_clicks)
    
    return @report_array
  end
end
