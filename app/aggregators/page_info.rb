require "net/http"
require "nokogiri"
require "open-uri"
require "iconv"

class PageInfo
	
	attr_accessor :main_url, :title, :description
	
	def initialize(raw_url)
		url = get_url(raw_url)
		if url
			self.main_url = url
		else
			return nil
		end
		
		begin
			doc = Nokogiri::HTML(open(self.main_url))
			self.title = doc.at_css("title").text unless doc.at_css("title").nil?
			meta_desc = doc.css("meta[name='description']").first 
			self.description = meta_desc['content'] unless (meta_desc.nil? || meta_desc['content'].nil?)
		rescue Exception => e
			return nil
		end
		
	end
	
	def title=(new_title)
		new_title.strip!
		["\n", "\t"].each { |remove| new_title.gsub!(remove, "") }
		
		write_attribute :title, new_title
	end
	
	def get_url(raw_url, redirected_times=10)
		return false if redirected_times <= 0
		
		begin
			url = URI.parse(raw_url)
			http = Net::HTTP.new(url.host, url.port) 
			resp, data = http.get(url.path, {})
		rescue Exception => e
			return false
		end
		
		case resp
			when Net::HTTPSuccess
				unless url.query.nil?
					query = url.query.split("&").reject { |e| e.match(/(utm_|feature|#\w+)/i) }.join('&')
					url.query = query.empty? ? nil : query
				end
				
				new_url = "http://" +url.host+url.path
				new_url += "?#{url.query}" unless ( url.query.nil? || url.query.empty? )
				
				puts "+#{redirected_times}: #{new_url}"
				return new_url
			when Net::HTTPRedirection
				begin
					redirect_url = URI.parse(resp.header['location'])
				rescue Exception => e
					puts e.to_s
					return false
				end
				
				puts "#{redirected_times}: #{redirect_url.to_s}"
				
				if redirect_url.host.nil?
					return raw_url
				else
					new_url = "http://" +redirect_url.host+redirect_url.path
					new_url += "?#{redirect_url.query}" unless ( redirect_url.query.nil? || redirect_url.query.empty? )
					return get_url(new_url, redirected_times - 1)
				end
		 	else
				return false
			end
	end
	
end