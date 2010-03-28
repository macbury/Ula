class Source < ActiveRecord::Base
	belongs_to :link, :counter_cache => true
	validates :content, :presence => true, :length => { :maximum => 255 }
	validates :avatar, :presence => true, :length => { :maximum => 255 }
	validates :name, :presence => true, :length => { :maximum => 255 }
end
