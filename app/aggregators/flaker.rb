require "httparty"

class Flaker
	include HTTParty 
  base_uri "api.flaker.pl"
  format :json 
	headers "Accept" => "application/json", "User-Agent" => "Aggregator"
  
	attr_accessor :last_id

  def fetchNext
		return fetch(self.last_id)
  end
  
  def fetch(blip_id=nil)
    begin
      out = self.class.get(blip_id.nil? ? "/api/html:false/type:flakosfera/source:links/avatars:medium/limit:50" : "/api/html:false/type:flakosfera/source:links/avatars:medium/limit:50/start:#{blip_id}") || []
    rescue Exception => e
      out = []
    end
		
		return [] if out.nil? || out.empty?
		
		links = []
		
		out["entries"].each do |status|
			
			links << {
				:type => :flaker,
				:id => status['id'].to_i,
				:user => status['user']['login'],
				:avatar => status['user']['avatar'],
				:body => status['text'],
				:link => status['link'],
				:created_at => status['created_at']
			}

			self.last_id = self.last_id.nil? ? status['id'].to_i : [status['id'].to_i, self.last_id].max
		end
		
		return links
  end 
   
end