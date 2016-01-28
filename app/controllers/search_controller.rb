class SearchController < ApplicationController
  
  #### autocomplete queries
  def autocomplete
    type = params[:type]
    q = params[:term]
    rgx = Regexp.escape(q)
    
    if type == "from_field"
      result = FromAddress.where(_id: /^#{rgx}/).all
    elsif type == "to_field"
      result = ToAddress.where(_id: /^#{rgx}/i).all
    end
    
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
      q['To'] = to_address
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

      @qstring = q
    end
    
    if @show_stats == "On"
      @tot_sent = Message.where(From: @addr).all.length
      @tot_received = Message.where(To: @addr).all.length

      @to_stats = Message.collection.aggregate([{"$match" => {"To" => @addr}},
                                                          {"$group" => {"_id" => "$From", "tot" => {"$sum" => 1}}},
                                                          {"$sort" => {"tot" => -1}},
                                                          {"$limit" => 1}]).first
      @from_stats = Message.collection.aggregate([{"$match" => {"From" => @addr}},
                                                          {"$group" => {"_id" => "$To", "tot" => {"$sum" => 1}}},
                                                          {"$sort" => {"tot" => -1}},
                                               {"$limit" => 1}]).first
    end
          
    @num_results = messages.length
    @results = Kaminari.paginate_array(messages).page(params[:page]).per(10)
    
  end

end