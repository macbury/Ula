require "httparty"

class Twitter
	include HTTParty 
  base_uri "api.twitter.com"
  format :json 
	headers "Accept" => "application/json", "User-Agent" => "Aggregator"
  
	attr_accessor :last_id

  def fetchNext
		return fetch(self.last_id)
  end
  
  def fetch(blip_id=nil)
    begin
      out = self.class.get("/1/statuses/public_timeline.json") || []
    rescue Exception => e
      out = []
    end
		
		return [] if out.nil? || out.empty?
		
		links = []
		
		out.each do |status|
			begin
				id = status['id'].to_i
			rescue Exception => e
				next
			end

			link = {
				:type => :twitter,
				:id => id,
				:user => status['user']['screen_name'],
				:avatar => "",
				:body => status['text'].gsub(/http:\/\/blip\.pl\/s\/([0-9]+)|http:\/\/www\.blip\.pl\/s\/([0-9]+)|http:\/\/blip\.pl\/tags\//i, ''),
				:created_at => status['created_at']
			}
			
			link[:avatar] = status['user']['profile_image_url']
			links << link
			
			#self.last_id = self.last_id.nil? ? status['id'].to_i : [status['id'].to_i, self.last_id].max
		end
		
		return links
  end 
   
end