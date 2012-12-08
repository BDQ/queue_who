class Report
  include MongoMapper::Document

  belongs_to :app

  key :jobs, Integer, default: 0
  key :failing, Integer, default: 0

  timestamps!
end
