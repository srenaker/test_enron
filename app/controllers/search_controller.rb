class SearchController < ApplicationController
  
  require "mongo"
  require "uri"
  include Mongo
  
  def get_connection
    return @db_connection if @db_connection
    if Rails.env == "development"
      @db_connection = MongoClient.new('localhost', 27017).db('enron2')
    elsif Rails.env == "production"
  
      db = URI.parse(ENV['MONGOHQ_URL'])
      db_name = db.path.gsub(/^\//, '')
      @db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
      @db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
      @db_connection
    end
  end
  
  #### autocomplete queries
  def from_field
    q = params[:term]
    rgx = Regexp.escape(q)
    result = FromAddress.where(:_id => /^#{rgx}/).all
    #result = db.collection("from_addresses").find(:_id => /^#{q}/)
    arr = {}
    result.each_with_index do |j, i|
      arr[i] = j._id
    end
    render :json => arr
  end
  
  def to_field
    q = params[:term]
    rgx = Regexp.escape(q)
    result = ToAddress.where(:_id => /^#{rgx}/i).all
    arr = {}
    result.each_with_index do |j, i|
      arr[i] = j._id
    end
    render :json => arr
  end
  
  
  #### messages search query
  def search_results
    
    from_address = params[:from_address]
    to_address = params[:to_address]      
    date = params[:datepicker]
    keywords = params[:keywords]
    @show_stats = params[:show_stats]
    @terms = []
    
    q = {}
    messages = []
    text_search = false
    
    # assemble query hash
    unless from_address.blank?
      @addr = from_address
      q['From'] = from_address
      @terms << from_address
    end
        
    unless to_address.blank?
      @addr = to_address
      q['To'] = [to_address]
      @terms << to_address
    end
    
    unless date.blank?
      start_date = Time.parse(date)
      end_date = start_date + 1.day
          
      date_comp = {}
      date_comp['$gte'] = start_date
      date_comp['$lt'] = end_date
      q['Date'] = date_comp
      @terms << date
    end
    
    unless keywords.blank?
      text_search = true
      q['$text'] = {'$search' => keywords}
      @keyword_array = keywords.split(' ')
      @terms << keywords
    end
    
    unless q.length == 0 # disallow blank searches which would return everything
      # arbitrary limit of 1000 results on text searches, just so we don't get bogged down
      # on very common terms
      text_search ? messages = Message.where(q).limit(1000).to_a : messages = Message.where(q).to_a
    end
    
    if @show_stats == "On"
      @tot_sent = Message.where(:From => @addr).all.length
      @tot_received = Message.where(:To => @addr).all.length
      db = get_connection 
      @to_stats = db.collection("messages").aggregate([{"$match" => {"To" => @addr}}, 
                                                          {"$group" => {"_id" => "$From", "tot" => {"$sum" => 1}}}, 
                                                          {"$sort" => {"tot" => -1}}, 
                                                          {"$limit" => 1}]).first
      @from_stats = db.collection("messages").aggregate([{"$match" => {"From" => @addr}}, 
                                                          {"$group" => {"_id" => "$To", "tot" => {"$sum" => 1}}}, 
                                                          {"$sort" => {"tot" => -1}}, 
                                                          {"$limit" => 1}]).first
    end
    
    # redirect_to root_path if q.length == 0   
       
    @num_results = messages.length
      
    # rudimentary deduplication of message bodies  
    # message_bodies = []
    #     messages.each do |m|
    #       if message_bodies.include?(m['body'])
    #         messages.delete(m)
    #       else
    #         message_bodies << m['body'] 
    #       end
    #     end       
    @num_results > messages.length ? @deduped = "<p>Some duplicate messages are not displayed." : @deduped = "" 
    
    @results = Kaminari.paginate_array(messages).page(params[:page]).per(10)
    
  end

end

 # highlight keywords, if any
 # - @keyword_array.each do |k|
 #    - match = body.match(/#{k}/i)
 #    - highlight = "<div class='highlighted'>#{match}</div>"
 #    - body.sub!(/#{match}/, highlight)