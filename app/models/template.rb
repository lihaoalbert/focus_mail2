class Template < ActiveRecord::Base
  after_create :dog_logger
  attr_accessible :file_name, :name,:img_url, :source
  has_many :entries
  has_many :campaigns

  def source
    if self.file_name
      @source = IO.readlines(Rails.root.join('lib/emails', "#{self.file_name}.html.erb")).join("").strip
    end
  end
  
  @astr = "nil"

  def source= (val)
    #p Rails.configuration.splitor_start
    #p Rails.configuration.splitor_end
    
    val = val.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
    val = val.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
    if(val.include? "$|")
      val = "Dear $|NAME|$ <br/>\nfrom $|EMAIL|$ <br/>\n" + val.lstrip
      
    else
      hval = val.scan(/<a[^>]*?href=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      ival = val.scan(/<img[^>]*?src=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      num = hval.length+ival.length
      @astr = Array.new(num){Array.new(2,0)}
      puts @astr.count
      @m = 0
      #html部分
      hval.each do |h1|
        val = val.gsub(Regexp.new(h1[1]), "$|href" + @m.to_s + "|$")
        @astr[@m][0] = "href" + @m.to_s
        @astr[@m][1] = h1[1].to_s
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
     #   if urlimg != "" && urlimg != nil then
     #     urlimgs = urlimg.split("/")
     #     uinum = urlimgs.length
     #     urlimg = urlimg
     #   end
        @astr[@m][1] = urlimg.to_s
        @m += 1
      end
      val = "Dear $|NAME|$ <br/>\nfrom $|EMAIL|$ <br/>\n" + val.lstrip
    end
    File.open(Rails.root.join("lib/emails", "#{self.file_name}.html.erb"), 'wb'){ |f| f.write(val) }
    puts @astr
  end
  def dog_logger
    @id = Template.where(["file_name = :f", { :f => self.file_name }]).first.id
    puts @id
    puts @astr
    if @astr != nil then
      @astr.each do |a|
        Entry.create({
          :template_id => @id,
          :name => a[0].to_s,
          :default_value => a[1].to_s
        })
      end
    end
  end
end
