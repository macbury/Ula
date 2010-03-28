require "httparty"

class Spinacz
	include HTTParty 
  base_uri "spinacz.pl"
  format :json 
	headers "Accept" => "application/json", "User-Agent" => "Aggregator"
  
	attr_accessor :last_id

  def fetchNext
		return fetch(self.last_id)
  end
  
  def fetch(blip_id=nil)
		query = { :HASH => "df2c2883036f607a817f3706613f3907" }
		#query[:from_id] = self.last_id unless self.last_id.nil?
    begin
      out = self.class.get("/feeds/getpublic.json", :query => query) || []
    rescue Exception => e
      out = []
    end
		
		return [] if out.nil? || out.empty?
		
		links = []
		
		out["feeds"].each do |status|
			begin
				id = status['feed_id'].to_i
				url = status['content_elements']['uris'].first
			rescue Exception => e
				next
			end
			
			link = {
				:type => :spinacz,
				:id => id,
				:user => status['login'],
				:avatar => status['avatar']['AV_48'],
				:body => status['content'],
				:link => url,
				:created_at => status['created_at']
			}
			
			links << link
			
			self.last_id = self.last_id.nil? ? id : [id, self.last_id].max
		end
		
		return links
  end 
   
end