class SearchController < ApplicationController
  
  def search_results
    @type = params[:type]
    
    if @type == 'from'
      @from_address = params[:from_address]
      messages = MongoMapper.database['messages'].find({'headers.From' => @from_address}).to_a
      
    elsif @type == 'keywords'
      @keywords = params[:keywords]
      messages = MongoMapper.database['messages'].find({"$text" => {"$search" => @keywords}}).limit(100).to_a
      
    end
    
    @num_results = messages.length
    
    messages.each do |m|
      unless 
    
    @results = Kaminari.paginate_array(messages).page(params[:page]).per(10)
  end

end
