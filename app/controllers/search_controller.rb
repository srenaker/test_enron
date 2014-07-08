class SearchController < ApplicationController
  
  def search_results
    @type = params[:type]
    
    if @type == 'from'
      @from_address = params[:from_address]
      messages = MongoMapper.database['messages'].find({'headers.From' => @from_address}).limit(100).to_a
      
    elsif @type == 'keywords'
      @keywords = params[:keywords]
      messages = MongoMapper.database['messages'].find({"$text" => {"$search" => @keywords}}).limit(100).to_a
      
    end
    
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
