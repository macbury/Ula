require "httparty"

class Jogger
	include HTTParty 
  base_uri "jogger.pl"
  format :xml 
	headers "Accept" => "application/json", "User-Agent" => "Aggregator"
  
	attr_accessor :last_id

  def fetchNext
		return fetch(self.last_id)
  end
  
  def fetch(blip_id=nil)
    begin
      out = self.class.get("/rss/content/html/50") || []
    rescue Exception => e
      out = []
    end
		
		return [] if out.nil? || out.empty?
		
		links = []
		
		out.each do |status|
			begin
				id = status['mid'].to_i
			rescue Exception => e
				next
			end

			link = {
				:type => :pinger,
				:id => id,
				:user => status['user']['login'],
				:avatar => "",
				:body => status['text'],
				:created_at => status['created_at']
			}
			
			link[:avatar] = status['user']['profile_image_url_thumb']
			links << link
			
			#self.last_id = self.last_id.nil? ? status['id'].to_i : [status['id'].to_i, self.last_id].max
		end
		
		return links
  end 
   
end