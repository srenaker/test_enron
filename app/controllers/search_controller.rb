class SearchController < ApplicationController
  
  #### autocomplete queries
  def from_field
    q = params[:term]
    result = FromAddress.where(:_id => /^#{q}/).all
    arr = {}
    result.each_with_index do |j, i|
      arr[i] = j._id
    end
    render :json => arr
  end
  
  def to_field
    q = params[:term]
    result = ToAddress.where(:_id => /^#{q}/).all
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
    @terms = []
    
    q = {}
    messages = []
    text_search = false
    
    # assemble query hash
    unless from_address.blank?
      q['From'] = from_address
      #q['headers.From'] = from_address
      @terms << from_address
    end
        
    unless to_address.blank?
      q['To'] = [to_address]
      #q['headers.To'] = [to_address]
      @terms << to_address
    end
    
    unless date.blank?
      start_date = Time.parse(date)
      end_date = start_date + 1.day
          
      date_comp = {}
      date_comp['$gte'] = start_date
      date_comp['$lt'] = end_date
      q['Date'] = date_comp
      #q['headers.Date'] = date_comp
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