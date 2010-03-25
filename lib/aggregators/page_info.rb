require "net/http"
require "nokogiri"
require "open-uri"

class PageInfo
	
	attr_accessor :main_url, :title, :description
	
	def initialize(raw_url)
		url = get_url(raw_url)
		if url
			self.main_url = url
		else
			return false
		end
		
		doc = Nokogiri::HTML(open(self.main_url))
		self.title = doc.at_css("title").text unless doc.at_css("title").nil?
		meta_desc = doc.css("meta[name='description']").first 
		self.description = meta_desc['content'] unless (meta_desc.nil? || meta_desc['content'].nil?)
	end
	
	def get_url(raw_url, redirected_times=10)
		return false if redirected_times <= 0
		
		begin
			puts "#{redirected_times}: #{raw_url}"
			url = URI.parse(raw_url)
			http = Net::HTTP.new(url.host, url.port) 
			resp, data = http.get(url.path, {})
		rescue Exception => e
			return false
		end
		
		case resp
			when Net::HTTPSuccess
				return raw_url
			when Net::HTTPRedirection
				return get_url(resp.header['location'], redirected_times - 1)
		 	else
				return false
			end
	end
	
end