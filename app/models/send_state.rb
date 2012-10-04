class SendState < ActiveRecord::Base
  attr_accessible :be_hits_number, :be_hits_ratio, :effective_operand_address, :has_sent_number, :open_number, :open_ratio, :reach_number, :reach_ratio, :send_ratio, :total_address_number, :campaign_id
end
