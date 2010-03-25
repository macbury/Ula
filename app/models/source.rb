class Source < ActiveRecord::Base
	belongs_to :link, :counter_cache => true
end
