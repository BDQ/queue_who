class App
  include MongoMapper::Document

  key :name, String
  has_many :reports
end
