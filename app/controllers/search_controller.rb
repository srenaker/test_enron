class SearchController < ApplicationController
  
  def search_results
    type = params[:type]
    
    if type == 'from'
      @from_address = params[:from_address]
      messages = Message.where('headers.From' => @from_address).all

      @results = Kaminari.paginate_array(messages).page(params[:page]).per(10)
    elsif type == 'keywords'
      @keywords = params[:keywords]
      @results = MongoMapper.database['messages'].find({"$text" => {"$search" => @keywords}}).limit(100).to_a
    end
    
  end

end
