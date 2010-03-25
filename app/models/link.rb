class Link < ActiveRecord::Base
	has_many :sources, :dependent => :delete_all
end
