class SearchController < ApplicationController

  def from_field
    @from_address = params[:from_address]
    @messages = Message.where('headers.From' => @from_address).limit(3).all
  end

end
