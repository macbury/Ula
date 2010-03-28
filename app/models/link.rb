class Link < ActiveRecord::Base
	has_many :sources, :dependent => :delete_all
	validates :title, :presence => true, :length => { :maximum => 255 }
	validates :url, :uniqueness => true, :length => { :maximum => 255, :minimum => 5 }
end
