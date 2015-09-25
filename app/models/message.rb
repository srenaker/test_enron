class Message
  include Mongoid::Document

  field :body, type: String
  field :headers, type: Hash

end
