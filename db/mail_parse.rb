require 'find'
require 'time'
require 'mongo' 
include Mongo

client = MongoClient.new
db = client['test'] 
coll = db['testColl']

file_num = 0
Find.find('.') do |e|
  if File.file?(e) and e =~ /\d+\./
    file_num +=1
    to = []
    from, date, subject = ''
    body = "\n" 
    line_num = 1
    headers = true
    File.readlines(e).each do |line|
      begin
        if line_num == 2 
          d = line.sub(/^Date: /, '')
          date = Time.parse(d)
        end

        from = line.sub(/^From: /, '').strip if line_num == 3

        if line_num == 4 
          begin
            to_line = line.sub(/^To: /, '').strip 
            to = to_line.split(', ')
          rescue
            next
          end
        end
        
        if line =~ /^Subject:/ and headers 
          subject = line.sub(/^Subject: /, '').strip
        end
        
        if line =~ /^X-FileName:/ # last line of the headers
          headers = false 
          next
        end
        
        body += line if !headers
        
      rescue
        puts "error with file #{e}"
      end  
      line_num += 1
    end
    coll.insert({:To => to, :From => from, :Date => date, :Subject => subject, :Body => body})
    
  end     
end
puts "found #{file_num} mail files"