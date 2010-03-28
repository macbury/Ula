require "httparty"

class Blip
	include HTTParty 
  base_uri "api.blip.pl"
  format :json 
	headers "Accept" => "application/json", "User-Agent" => "Aggregator", "X-Blip-api" => "0.02"
  
	attr_accessor :last_id

  def fetchNext
		return fetch(self.last_id)
  end
  
  def fetch(blip_id=nil)
		query = { :include => "user,user[avatar]" }
    begin
      out = self.class.get(blip_id.nil? ? "/statuses/all" : "/statuses/#{blip_id}/all_since", :query => query) || []
    rescue Exception => e
      out = []
    end
		
		return [] if out.nil? || out.empty?
		
		links = []
		
		out.each do |status|
			
			link = {
				:type => :blip,
				:id => status['id'].to_i,
				:user => status['user']['login'],
				:avatar => "",
				:body => status['body'].gsub(/http:\/\/blip\.pl\/s\/([0-9]+)|http:\/\/www\.blip\.pl\/s\/([0-9]+)|http:\/\/blip\.pl\/tags\//i, ''),
				:created_at => status['created_at']
			}
			
			link[:avatar] = status['user']['avatar']['url_50'] unless status['user']['avatar'].nil?
			links << link
			
			self.last_id = self.last_id.nil? ? status['id'].to_i : [status['id'].to_i, self.last_id].max
		end
		
		return links
  end 
   
end