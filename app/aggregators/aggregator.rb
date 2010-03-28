require "app/aggregators/blip"
require "app/aggregators/twitter"
require "app/aggregators/flaker"
require "app/aggregators/spinacz"
require "app/aggregators/page_info"
require "uri"
require "net/http"
require "open-uri"
require "cgi"
#require "json"
require "iconv"

class Aggregator
	
	LINK_REGEXP = /((<\w+.*?>|[^=!:'"\/]|^)((?:https?:\/\/)|(?:www\.)www.*)([-\w]+(?:\.[-\w]+)*(?::\d+)?(?:\/(?:(?:[~\w\+@%=\(\)-]|(?:[,.;:][^\s$]))+)?)*(?:\?[\w\+@%&=.;-]+)?(?:\#[\w\-]*)?)([[:punct:]]|<|$|))/x
	
	def initialize
		@blip = Blip.new
		@twitter = Twitter.new
		@flaker = Flaker.new
		@spinacz = Spinacz.new
		
		@black_list = []
		File.open("#{Rails.root}/config/ignore_sites.txt", "r").each do |line|
			@black_list << /#{line}/i
		end
	end
	
	def banned?(url)
		begin
			url = Uri.parse(url)
			banned = false
			@black_list.each do |banned_host|
				if url.host =~ banned_host
					banned = true
					break
				end
			end
			
			return banned
		rescue Exception => e
			return false
		end
		
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
				puts "[#{Time.current}] Pobieranie linka - #{raw_link[:type].to_s}"
				next if raw_link[:type] == :twitter && language?(raw_link[:body]) != "pl"
				
				pageInfo = PageInfo.new(raw_link[:link] || $1.to_s.strip)
				next if (pageInfo.nil? || banned?(pageInfo.main_url))
				link = Link.find_or_initialize_by_url(pageInfo.main_url)
				if link.new_record?
					link.title = pageInfo.title
					link.description = pageInfo.description
					link.save
				end
				
				next unless link.valid?
				
				source = Source.find_or_initialize_by_name_and_link_id_and_transport(raw_link[:user], link.id, raw_link[:type].to_s)
				
				if source.new_record?
					source.content = raw_link[:body]
					source.transport_id = raw_link[:id]
					source.avatar = raw_link[:avatar]
					source.save
				end
			end
		end
		
	end
	
end