require 'zip/zip'
require 'zip/zipfilesystem'
class Template < ActiveRecord::Base
  after_save :dog_logger
  attr_accessible :file_name, :name,:img_url, :source, :zip_url, :zip_name
  has_many :entries
  has_many :campaigns
  File_extname = [".rar",".7z",".zip"]
  File_target = "public/files"
  
  def set_file_values(file_url,file_name)
    self.zip_url = file_url
    self.zip_name = file_name
  end

  def source
    if self.file_name
      @source = IO.readlines(Rails.root.join('lib/emails', "#{self.file_name}.html.erb")).join("").strip
    end
  end
  
  @astr = "nil"

  def source= (val)
    #p Rails.configuration.splitor_start
    #p Rails.configuration.splitor_end
    if val != "" && val != nil then    
      val = val.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
      val = val.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
      if val.to_s.split(val.gsub(/<body.*>(.|\s)*/, "&&").split("&&")[0].to_s).length != 0 then
        val = val.to_s.split(val.gsub(/<body.*>(.|\s)*/, "&&").split("&&")[0].to_s)[1]
        val = val.gsub(/<body.*>/, "")
        val = val.gsub(/<\/body>(.|\s)*/, "")
      end
      val = val.chomp.strip
      if(val.include? "$|")
        val = "Dear $|NAME|$ <br/>\nfrom $|EMAIL|$ <br/>\n" + val.lstrip
        
      else
        hval = val.scan(/<a[^>]*?href=(['"\s]?)(([^'"\s])*)[^>]*?>/)
        ival = val.scan(/<img[^>]*?src=(['"\s]?)(([^'"\s])*)[^>]*?>/)
        num = hval.length+ival.length
        @astr = Array.new(num){Array.new(2,0)}
        #puts @astr.count
        @m = 0
        #html部分
       # hval.each do |h1|
	hvala = Array.new()
        hval.each do |hl|
          hvala.push hl[1]
        end
        hvala = hvala.sort.reverse
        slist = hvala.clone  
        for i in 0..(slist.length - 1)
          for j in 0..(slist.length - i - 2)
            if ( slist[j + 1].size <=> slist[j].size ) == -1
              slist[j], slist[j + 1] = slist[j + 1], slist[j]
            end
          end
        end
        #html部分
        #hvala.each do |h1|
        num = slist.length-1
        for n in 0..num
          val = val.gsub(Regexp.new(slist[num-n].to_s.gsub(/\?/,'\?').gsub(/\$/,'\$')), "$|href" + @m.to_s + "|$")
          #val = val.gsub(Regexp.new(h1[1]), "$|href" + @m.to_s + "|$")
          #val = val.gsub(Regexp.new(h1[1].gsub(/\?/,'\?').gsub(/\$/,'\$')), "$|href" + @m.to_s + "|$") #修改url中的‘?和$’和正则表达式中的'?和$'冲突
          @astr[@m][0] = "href" + @m.to_s
          @astr[@m][1] = slist[num-n].to_s
          @m += 1
        end
        #text部分
        #tval = val.scan(/<a[^>]+>(\w+)<\/a>/)
        ##@n = 0
        #tval.each do |t1|
        #  val = val.gsub(Regexp.new(t1[0]), "$|text" + @m.to_s + "|$")
        #  @astr[@m][0] = "text" + @m.to_s
        #  @astr[@m][1] = t1[0].to_s
        #  @m += 1
        #end
        #img部分
        ival.each do |i1|
          val = val.gsub(Regexp.new(i1[1]), "$|img" + @m.to_s + "|$")
          @astr[@m][0] = "img" + @m.to_s
          urlimg = i1[1].to_s
          if urlimg != "" && urlimg != nil then
            urlimgs = urlimg.split("/")
            uinum = urlimgs.length
            urlimg = urlimgs[uinum-1]
          end
          @astr[@m][1] = urlimg.to_s
          @m += 1
        end
        val = "Dear $|NAME|$ <br/>\nfrom $|EMAIL|$ <br/>\n" + val.lstrip
      end
      File.open(Rails.root.join("lib/emails", "#{self.file_name}.html.erb"), 'wb'){ |f| f.write(val) }
      #puts @astr
      else
        File.open(Rails.root.join("lib/emails", "#{self.file_name}.html.erb"), 'wb')
    end
  end
  
  def dog_logger
    @Template = Template.where(["file_name = :f", { :f => self.file_name }]).first
    if @astr != nil then
      Entry.delete_all("template_id=#{@Template.id}")
      @astr.each do |a|
        Entry.create({
          :template_id => @Template.id,
          :name => a[0].to_s,
          :default_value => a[1].to_s
        })
      end
      if @Template != nil then
        @Template.update_attributes(:zip_url => nil, :zip_name => nil) 
      end
    else
      if self.zip_name != "" && self.zip_name != nil then
        Entry.delete_all("template_id=#{@Template.id}")
        zipfile_name = Rails.root.join(File_target, self.zip_url)
        zipfile_path = zipfile_name.to_s.split(".")[0]
        FileUtils.makedirs(zipfile_path)
        Zip::ZipFile::open(zipfile_name.to_s) do |zf|
          zf.each do |e|
             fpath = File.join(zipfile_path, e.name)
             FileUtils.mkdir_p(File.dirname(fpath))
             zf.extract(e, fpath)
          end
        end
        if FileTest::exist?(File.join(zipfile_path, "index.html")) then
          val = File.open(File.join(zipfile_path, "index.html")).read
          val = val.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
          val = val.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
          vala = val.to_s.split(val.gsub(/<body.*>(.|\s)*/, "&&").split("&&")[0].to_s)
          if vala.size > 1 then
            val = vala[1]
            val = val.gsub(/<body.*>/, "")
            val = val.gsub(/<\/body>(.|\s)*/, "")
          end
          val = val.chomp.strip
          if(val.include? "$|")
            val = "Dear $|NAME|$ <br/>\nfrom $|EMAIL|$ <br/>\n" + val.lstrip
            
          else
            hval = val.scan(/<a[^>]*?href=(['"\s]?)(([^'"\s])*)[^>]*?>/)
            ival = val.scan(/<img[^>]*?src=(['"\s]?)(([^'"\s])*)[^>]*?>/)
            num = hval.length+ival.length
            @astr = Array.new(num){Array.new(2,0)}
            #puts @astr.count
            @m = 0
            #html部分
            hvala = Array.new()
            hval.each do |hl|
              hvala.push hl[1]
            end
            hvala = hvala.sort.reverse
            slist = hvala.clone  
            for i in 0..(slist.length - 1)
              for j in 0..(slist.length - i - 2)
                if ( slist[j + 1].size <=> slist[j].size ) == -1
                  slist[j], slist[j + 1] = slist[j + 1], slist[j]
                end
              end
            end
            #html部分
            #hvala.each do |h1|
            num = slist.length-1
            for n in 0..num
              val = val.gsub(Regexp.new(slist[num-n].to_s.gsub(/\?/,'\?').gsub(/\$/,'\$')), "$|href" + @m.to_s + "|$")
            #hval.each do |h1|
             # val = val.gsub(Regexp.new(h1[1].gsub(/\?/,'\?').gsub(/\$/,'\$')), "$|href" + @m.to_s + "|$")
              @astr[@m][0] = "href" + @m.to_s
              @astr[@m][1] = slist[num-n].to_s
              @m += 1
            end
            #text部分
            #tval = val.scan(/<a[^>]+>(\w+)<\/a>/)
            ##@n = 0
            #tval.each do |t1|
            #  val = val.gsub(Regexp.new(t1[0]), "$|text" + @m.to_s + "|$")
            #  @astr[@m][0] = "text" + @m.to_s
            #  @astr[@m][1] = t1[0].to_s
            #  @m += 1
            #end
            #img部分
            ival.each do |i1|
              val = val.gsub(Regexp.new(i1[1]), "$|img" + @m.to_s + "|$")
              @astr[@m][0] = "img" + @m.to_s
              urlimg = i1[1].to_s
              if urlimg != "" && urlimg != nil then
                urlimgs = urlimg.split("/")
                uinum = urlimgs.length
                urlimg = urlimgs[uinum-1]
              end
              @astr[@m][1] = urlimg.to_s
              @m += 1
            end
            val = "Dear $|NAME|$ <br/>\nfrom $|EMAIL|$ <br/>\n" + val.lstrip
          end
          File.open(Rails.root.join("lib/emails", "#{self.file_name}.html.erb"), 'wb'){ |f| f.write(val) }
        end
        if @astr != nil then
          @astr.each do |a|
            Entry.create({
              :template_id => @Template.id,
              :name => a[0].to_s,
              :default_value => a[1].to_s
            })
          end
        end
      end
    end
  end
end
