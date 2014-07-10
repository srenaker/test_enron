class SearchController < ApplicationController
  
  def search_results
    
    @from_address = params[:from_address]
    @to_address = params[:to_address]      
    @date = params[:date]
    @keywords = params[:keywords]
    
    q = {}
    
    # assemble query hash
    unless @from_address.blank?
      q['headers.From'] = @from_address
    end
        
    unless @to_address.blank?
      q['headers.To'] = [@to_address]
    end
    
    unless @keywords.blank?
      q['$text'] = {'$search' => @keywords}
    end
   
        
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
