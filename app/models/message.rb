class Message
  include MongoMapper::Document

  key :body, String
  key :headers, Hash

end
