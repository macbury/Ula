require "httparty"

class FriendFeed
	include HTTParty 
  base_uri "friendfeed-api.com"
  format :json 
	headers "Accept" => "application/json", "User-Agent" => "Aggregator"
  
	attr_accessor :last_id
	
	def initialize
		self.last_id = 0
	end
	
  def fetchNext
		return fetch(self.last_id)
  end
  
  def fetch(blip_id=nil)
    begin
      out = self.class.get("/v2/feed/public") || []
    rescue Exception => e
      out = []
    end
		
		return [] if out.nil? || out.empty?
		
		links = []
		
		out["entries"].each do |status|
			id = status['id'].to_i

			links << {
				:type => :friendfeed,
				:id => id,
				:user => status['from']['id'],
				:avatar => nil,
				:body => status['body'],
				:created_at => status['date']
			}

			self.last_id = self.last_id.nil? ? status['id'].to_i : [status['id'].to_i, self.last_id].max
		end
		
		return links
  end 
   
end