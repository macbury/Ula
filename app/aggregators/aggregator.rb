require "app/aggregators/blip"
require "app/aggregators/twitter"
require "app/aggregators/flaker"
require "app/aggregators/spinacz"
require "app/aggregators/pinger"
require "app/aggregators/page_info"
require "uri"
require "net/http"
require "open-uri"
require "cgi"


class Aggregator
	
	LINK_REGEXP = /((<\w+.*?>|[^=!:'"\/]|^)((?:https?:\/\/)|(?:www\.)www.*)([-\w]+(?:\.[-\w]+)*(?::\d+)?(?:\/(?:(?:[~\w\+@%=\(\)-]|(?:[,.;:][^\s$]))+)?)*(?:\?[\w\+@%&=.;-]+)?(?:\#[\w\-]*)?)([[:punct:]]|<|$|))/x
	
	def initialize
		@blip = Blip.new
		@twitter = Twitter.new
		@flaker = Flaker.new
		@spinacz = Spinacz.new
		@pinger = Pinger.new
		
		@black_list = []
		File.open("config/ignore_sites.txt", "r").each { |line| @black_list << line.strip }
	end
	
	def banned?(url)
		begin
			url = URI.parse(url)
		rescue Exception => e
			return false
		end
		
		banned = false
		@black_list.each do |banned_host|
			if url.host =~ /#{banned_host}/i
				banned = true
				break
			end
		end
		
		return banned
	end
	
	def language?(content)
		base_url = 'http://www.google.com/uds/GlangDetect?v=1.0&q='
		url = base_url + CGI.escape(content)
		response = Net::HTTP.get_response(URI.parse(url))
		result = JSON.parse(response.body)
		puts "[#{Time.current}] Jezyk tresci: #{result['responseData']['language']}"
		return result['responseData']['language']
	end
	
	def aggregate
		links = []
		
		puts "Pinger..."
		links += @pinger.fetchNext
		puts "Spinacz..."
		links += @spinacz.fetchNext
		puts "Flaker..."
		links += @flaker.fetchNext
		puts "Twitter..."
		links += @twitter.fetchNext
		puts "Blip..."
		links += @blip.fetchNext
		
		puts "Parsowanie..."
		
		links.each do |raw_link|

			if raw_link[:body] =~ LINK_REGEXP || raw_link[:link]
				puts "[#{Time.current}] Wykryto link: #{raw_link[:type].to_s}"
				next if raw_link[:type] == :twitter && language?(raw_link[:body]) != "pl"
				
				pageInfo = PageInfo.new(raw_link[:link] || $1.to_s.strip)
				if (pageInfo.nil? || banned?(pageInfo.main_url))
					puts "Strona zbanowana!"
					next 
				end
				link = Link.find_or_initialize_by_url(pageInfo.main_url)
				if link.new_record?
					puts "Dodano nowy link: #{pageInfo.title}"
					link.title = pageInfo.title
					link.description = pageInfo.description
					link.save
				end
				
				next unless link.valid?
				
				source = Source.find_or_initialize_by_name_and_link_id(raw_link[:user], link.id, raw_link[:type].to_s)
				
				if source.new_record?
					puts "Dodano nowe zrodlo: #{raw_link[:user]}"
					source.content = raw_link[:body].gsub('\u003C', '"').gsub('\u003E', '"').gsub(/<\/?[^>]*>/, "")
					source.transport_id = raw_link[:id]
					source.transport = raw_link[:type].to_s
					source.avatar = raw_link[:avatar]
					source.save
				end
			end
		end
		
	end
	
end