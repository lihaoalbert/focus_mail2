class CreateSendStates < ActiveRecord::Migration
  def change
    create_table :send_states do |t|
      t.integer :total_address_number                                  #总地址数
      t.integer :effective_operand_address                             #有效地址数
      t.integer :has_sent_number                                       #已发送数
      t.float :send_ratio                                              #发送率  
      t.integer :reach_number                                          #到达数  
      t.float :reach_ratio                                             #到达率  
      t.integer :open_number                                           #打开数  
      t.float :open_ratio                                              #打开率  
      t.integer :be_hits_number                                        #被点击数
      t.float :be_hits_ratio                                           #点击率  
      t.integer :campaign_id                                           #模板id

      t.timestamps
    end
  end
end
