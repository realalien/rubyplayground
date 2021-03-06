#encoding:UTF-8

require 'mongoid'

# Note: this class is to make the json structure more explicit!
class XinMinDailyArticlesModelForCollector
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated  # TODO: it actually mingles with the weibo's data. How to change default column updated_at
  
  
  field :article_title, type: String
  field :article_link, type: String
  field :raw_content, type: String
  #field :content, type: String
  field :date_of_news, type: Date
  
  validates :article_link,  :uniqueness => {:scope => :date_of_news}
    
  index({ date_of_news:1}, { name: "xm_articles_idx_date"} )   
    
  scope :on_specific_date, lambda { |date| where(:date_of_news.gte => date, :date_of_news.lte => date+1)  if date }
  scope :between_dates, lambda { | start_date, end_date | where(:date_of_news.gte => start_date, :date_of_news.lte => end_date+1) if start_date && end_date }
    
  belongs_to :pageIndex, class_name: "XinMinDailyPageIndexModelForCollector", inverse_of: :articles
  
  has_many :themes, class_name: "HackingTheme", inverse_of: :article4hacktheme, autosave: true, dependent: :delete
  
  embeds_many :infos, class_name: "DistilledData", inverse_of: :article4distilleddata


end

# NOTE: 2013.2.17. Considering that more tools are coming to re-process formerly collected data, we need a way to process all articles on particular days, 
#   also, this objects can also maintain the some information about experiments already applied. 
class XinMinDailyPageIndexModelForCollector
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  field :page_title, type: String
  field :page_link, type: String
  
  # for use of 'checking if downloaded or not', 'quick retrieving  of particular page', WATCH OUT: if missing a page, leave that empty rather than reusing it.
  field :seq_no, type:Integer
  field :date_of_news, type: Date
  
  scope :on_specific_date, lambda { |date| where(:date_of_news.gte => date, :date_of_news.lte => date+1)  if date }
  scope :with_seq_no, lambda { |seq| where(seq_no: seq) if seq}
  
  index({ date_of_news:1}, { name: "xm_idx_date"} ) 
  index({ date_of_news: 1 , seq_no: 1 }, { unique: true , name: "xm_idx_date_pageindex" })
  
  has_many :articles, class_name:"XinMinDailyArticlesModelForCollector", inverse_of: :pageIndex, autosave: true,  dependent: :delete
  
  validates :seq_no,  :uniqueness => {:scope => :date_of_news}

end


# ------------------------------------------------------------------------------

# Notes:
# * In order to re-engineer the news articles, various degrees of readers' activities will
#   be involved. This class is only a model proof-of-concept, it is wishfully to be generalized 
#   enough to write down info which are factors of interest, part of process without whole pic.
#   can be reused for knowledge engineering.
class Note
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  
end

# NOTE:  'it seems Note and HackTheme can be polymorphesized into one class', while for the purpose
# of distinguishing the machine-code-based analysis with human manual ones, or even future versatile
# evolving, these two classes are intentionally separated concepts!


# For newspaper hacking games, it seems meanless to relentlessly grab all the news for reprocessing.
# the instance of this class is merely referring some articles of interest.
class HackingTheme
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated 
  
  field :theme_name, type: String
  field :process_by, type: String  # probably a git commit
    
  belongs_to :article4hacktheme, class_name: "XinMinDailyArticlesModelForCollector", inverse_of: :themes

  #  parse results are list as other attributes
end

# hacking theme should more like a user-based activity class, DistilledData is thought to record parsed info.

class DistilledData
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated 
  
  field :process_by, type: String  # probably a git commit
    
  embedded_in :article4distilleddata, class_name: "XinMinDailyArticlesModelForCollector", inverse_of: :infos

  #  parse results are list as other attributes
end






