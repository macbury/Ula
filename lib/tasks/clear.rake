namespace :links do
	task :clear => :environment do
		Link.where("sources_count <= 1").each(&:destroy)
	end
end