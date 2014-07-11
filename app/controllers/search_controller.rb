class SearchController < ApplicationController
  
  ## possible new features:
  # turn on/off search term anchored to beginning of to/from address string
  # limit number of addresses in to: field
  # aggregate queries for most messages sent, # of messages sent
  # documentation: explain some challenges of the search system
  
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
    result = FromAddress.where(:_id => /^#{q}/).all
    arr = {}
    result.each_with_index do |j, i|
      arr[i] = j._id
    end
    render :json => arr
  end
  
  
  #### messages search query
  def search_results
    
    @from_address = params[:from_address]
    @to_address = params[:to_address]      
    @date = params[:datepicker]
    @keywords = params[:keywords]
    
    q = {}
    
    # assemble query hash
    unless @from_address.blank?
      q['headers.From'] = @from_address
    end
        
    unless @to_address.blank?
      q['headers.To'] = [@to_address]
    end
    
    unless @date.blank?
      start_date = Time.parse(@date)
      end_date = start_date + 1.day
      
      
      date_comp = {}
      date_comp['$gte'] = start_date
      # date_comp['$gte'] = Time.parse("2001-04-04")
      date_comp['$lt'] = end_date
      # date_comp['$lt'] = Time.parse("2001-04-06")

      q['headers.Date'] = date_comp
    end
    
    unless @keywords.blank?
      q['$text'] = {'$search' => @keywords}
    end
   
    redirect_to root_path if q.length == 0 
        
    messages = Message.where(q).to_a
       
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
