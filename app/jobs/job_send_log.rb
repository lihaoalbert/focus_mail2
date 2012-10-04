require 'resque'
require 'zlib' 
require 'open-uri'
class Job_send_log
  @queue = "job_test1"
  def self.perform
    Campaign.all.each do |campaign|
      if File.exists?('config/readfile.yml')
        readfile = YAML.load_file('config/readfile.yml')
        Job_send_log.new.dbsave(readfile["readfile"].to_s,readfile["readzg"])
        sent_number = SendmailLog.find(:all, :select => "max(to_email) as to_email", :group => "to_email", :conditions => "type_email= 'Mail.LR' and campaign_id = '#{campaign.id}'").count
        memberarray = Array.new
        campaign.lists.collect(&:members).flatten.each do |member|
          memberarray.push(member.id)
        end
        members = Member.find(memberarray.uniq)
        member_number = members.count
        memberstr = memberarray.join(",")
        if memberstr == "" || memberstr == nil then
          memberstr = 0
        end
        membertype_number = Member.where("type_email = 1 and id in (#{memberstr})").count
        if member_number == 0 then
          send_ratio = 0.0
        else
          send_ratio = sent_number.to_f/member_number.to_f
        end
        reach_number = SendmailLog.find(:all, :select => "max(to_email) as to_email", :group => "to_email", :conditions => "tf_email = 'OK' and type_email= 'Mail.LR' and campaign_id = '#{campaign.id}'").count
        if sent_number == 0 then
          reach_ratio = 0.0
        else
          reach_ratio = reach_number.to_f/sent_number.to_f
        end
        open_number = Click.where("campaign_id = '#{campaign.id}'").count
        hits_number = Track.where("campaign_id = '#{campaign.id}'").count
        if reach_number == 0 then
          open_ratio = 0.0
          hits_ratio = 0.0
        else
          open_ratio = open_number.to_f/reach_number.to_f
          hits_ratio = hits_number.to_f/reach_number.to_f
        end
        SendState.create({
          :campaign_id => campaign.id,
          :total_address_number => member_number,
          :effective_operand_address => membertype_number,
          :has_sent_number => sent_number,
          :send_ratio => send_ratio,
          :reach_number => reach_number,
          :reach_ratio => reach_ratio,
          :open_number => open_number,
          :open_ratio => open_ratio,
          :be_hits_number => hits_number,
          :be_hits_ratio => hits_ratio
        })
      end
    end
  end
  
  def dbsave(filepath,filepathzg)
    if File.exists?(filepath)
      maillog = IO.readlines(filepath)
      sendmaillognumber = SendmailLogNumber.where("date(created_at)=date(now())")
      #获取昨天剩余的log
      if sendmaillognumber.all.count == 0 then
        time = Time.now - 86400
        lastday = time.strftime("%y%m%d")
        logym = time.strftime("%Y_%m")
        filepathzg = filepathzg + logym + "/mgmailerd.log." + lastday.to_s + ".gz"
        if File.exists?(filepathzg) then
          source = open(filepathzg)
          gz = Zlib::GzipReader.new(source) 
          result = gz.readlines
          sendmaillognumber = SendmailLogNumber.where("date(created_at)=date(#{lastday})")
          if sendmaillognumber.all.count > 0 then
            slnupdate = sendmaillognumber.first
            readlog(slnupdate.number_log.to_i,result)
            slnupdate = sendmaillognumber.first
            slnupdate.update_attributes(:number_log => result.count, :updated_at => Time.now() + 28800 )
          end
        end
        #当天第一次log写入
        SendmailLogNumber.create({:number_log => maillog.count, :created_at => Time.now() + 28800, :updated_at => Time.now() + 28800 })
        readlog(0,maillog)
      else
        slnupdate = sendmaillognumber.first
        readlog(slnupdate.number_log.to_i,maillog)
        if slnupdate.number_log < maillog.count then
          slnupdate.update_attributes(:number_log => maillog.count, :updated_at => Time.now() + 28800 )
        end
      end
    end
  end
  
  #读写log的方法
  def readlog(num,maillog)
    arr1 = Array.new
    for i in num..maillog.count-1 do
      arr2 = Array.new 
      m= maillog[i].to_s
      if (m =~ /Warning/) == nil then
        if (m =~ /Shutdown successfully./) == nil then
          marray = m.split("] ")
          marray.each do |ma|
            if ma[0,1] == "[" then
              arr2.push(ma.delete"[")
            else
              marray1 = ma.split("> -> ")
              marray2 = marray1[0].to_s.split("<")
              arr2.push(marray2[0])
              arr2.push(marray2[1])
              marray3 = marray1[1].to_s.split(")[")
              marray3.each do |ma3|
                if (ma3 =~ /\>\s\(/) != nil then
                  marray4 = ma3.to_s.split("> (")
                  marray4.each do |ma4|
                    if ma4["<"] != nil then
                      arr2.push(ma4.delete"<")
                    else
                      arr2.push(ma4)
                    end
                  end
                else
                  marray5 = ma3.split("][")
                  marray5.each do |ma5|
                    if ma5["["] != nil then
                      arr2.push(ma5.delete"[")
                    else
                      if ma5["]("] != nil then
                        marray6 = ma5.split("](")
                        marray6.each do |ma6|
                          arr2.push(ma6)
                        end
                      else
                        if ma5["]"] != nil then
                          arr2.push(ma5.delete"]")
                        else
                          if ma5["MGTAGLOG"] == nil then
                            arr2.push(ma5)
                          end
                        end
                      end
                    end
                  end
                end
              end
              arr1.push(arr2)
            end
          end
        end
      end
    end
    arr1.each do |a1|
      if a1.count == 10 then
        send_date = a1[0]
        course_id = a1[1]
        type_email = a1[2]
        from_email = a1[3] 
        to_email = a1[4]
        title_email = a1[5]
        tf_email = a1[6]
        test1 = a1[7]
        test2 = a1[8]
        coding_email = a1[9]
      else
        send_date = a1[0]
        course_id = a1[1]
        type_email = a1[2]
        from_email = a1[3] 
        to_email = a1[4]
        title_email = a1[5]
        tf_email = a1[6]
        test1 = nil
        test2 = a1[7]
        coding_email = a1[8]
      end
      campaign_id = nil
      if from_email != "" && from_email != nil then
        from_email_array = from_email.to_s.split("@")
        from_email_name_array = from_email_array[0].to_s.split("_")
        anum = from_email_name_array.count
        if from_email_name_array[anum-1] == "0" then
          campaign_id = from_email_name_array[anum-2]
        end
      end
      if tf_email == "ok" then
        member = Member.where("email = '#{to_email}'").first
        member.update_attributes(:type_email => 1)
      end
      SendmailLog.create({
        :send_date => send_date,
        :course_id => course_id,
        :type_email => type_email == "Mail.RR" ? "Mail.LR" : type_email,
        :from_email => from_email, 
        :to_email => to_email,
        :title_email => (title_email != nil && title_email != "") ? title_email.split('/')[0] : title_email,
        :tf_email => tf_email,
        :test1 => test1,
        :test2 => test2,
        :coding_email => coding_email,
        :campaign_id => campaign_id
      })
    end
  end
end
