class ClicksController < ApplicationController
  def index
    @clicks = Click.includes(:member, :campaign, :link).paginate(:page => params[:page], :per_page => 10)
    
    @campaign_id_array = Click.find(:all,
      :select => "DISTINCT campaign_id AS CampaignId,campaigns.name AS CampaignName",
      :joins =>"LEFT JOIN campaigns ON campaigns.id = clicks.campaign_id")
      
    @campaign_click_report = Array.new
    @campaign_id_array.each do |campaign|
				  click_report = Click.find(:all,
				    :select => "COUNT(DISTINCT clicks.member_id) AS TrackNumber,COUNT(clicks.member_id) AS MemberClicks",
				    :conditions => ["campaign_id = #{campaign.CampaignId}"])
				    
				  total_mem = Member.find(:all,
				    :select => "COUNT(DISTINCT email) AS TotalMem",
				    :joins => "LEFT JOIN lists ON lists.id = members.list_id LEFT JOIN campaign_lists ON campaign_lists.list_id = lists.id LEFT JOIN campaigns ON campaigns.id = campaign_lists.campaign_id",
				    :conditions => ["campaign_id = #{campaign.CampaignId}"])
				  report = Array.new
				  report.push(campaign.CampaignName,total_mem[0].TotalMem,click_report[0].TrackNumber,click_report[0].MemberClicks,campaign.CampaignId)
				  @campaign_click_report.push(report)
    end

    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clicks }
    end
  end
end
