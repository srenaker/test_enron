class SearchController < ApplicationController
  
  def search_results
    
    @from_address = params[:from_address]
    @to_address = params[:to_address]      
    @keywords = params[:keywords]
    
    qs = []
    
    # assemble query strings
    unless @from_address.nil?
      from_qs = "'headers.From' => #{@from_address}"
      qs << from_qs
    end
        
    unless @to_address.nil?
      to_qs = "'headers.To' => #{@to_address}"
      qs << to_qs
    end
    
    unless @keywords.nil?
      keywords_qs = "'$text' => {'$search' => #{@keywords}}"
      qs << keywords_qs 
    end
    
    query_string = qs.join(', ')
    
    puts "\n\nquery string is #{query_string}\n\n"
    
    messages = MongoMapper.database['messages'].find({query_string}).limit(100).to_a
      
    
    @num_results = messages.length
      
    message_bodies = []
    messages.each do |m|
      if message_bodies.include?(m['body'])
        puts "found a dupe"
        messages.delete(m)
      else
        message_bodies << m['body'] 
      end
    end 
      
    @num_results > messages.length ? @deduped = "<p>Some duplicate messages are not displayed." : @deduped = "" 
    
    @results = Kaminari.paginate_array(messages).page(params[:page]).per(10)
    
  end

end
