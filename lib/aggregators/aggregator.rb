require "lib/aggregators/blip"
require "lib/aggregators/page_info"

class Aggregator
	
	LINK_REGEXP = /((<\w+.*?>|[^=!:'"\/]|^)((?:https?:\/\/)|(?:www\.)www.*)([-\w]+(?:\.[-\w]+)*(?::\d+)?(?:\/(?:(?:[~\w\+@%=\(\)-]|(?:[,.;:][^\s$]))+)?)*(?:\?[\w\+@%&=.;-]+)?(?:\#[\w\-]*)?)([[:punct:]]|<|$|))/x
	
	def initialize
		@blip = Blip.new
	end
	
	def aggregate
		links = []
		links += @blip.fetchNext
		
		links.each do |raw_link|

			if raw_link[:body] =~ LINK_REGEXP
				pageInfo = PageInfo.new($1.to_s.strip)
				next unless pageInfo
				link = Link.find_or_initialize_by_url(pageInfo.main_url)
				if link.new_record?
					link.title = pageInfo.title
					link.description = pageInfo.description
					link.save
				end
				
				source = Source.find_or_initialize_by_name_and_link_id(raw_link[:user], link.id)
				
				if source.new_record?
					source.content = raw_link[:body]
					source.save
				end
			end
		end
		
	end
	
end