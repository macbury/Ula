#!/usr/bin/env ruby

require "yaml"
require "lib/aggregators/aggregator"

# You might want to change this
ENV["RAILS_ENV"] ||= "development"
require File.dirname(__FILE__) + "/../../config/environment"

def load_config
  daemon_config = YAML::load(File.open("#{Rails.root}/config/daemons/aggregator.yml"))[Rails.env]
end

$running = true
Signal.trap("TERM") do 
  $running = false
end

ActiveRecord::Base.logger = Logger.new(STDOUT)
config = load_config
aggregator = Aggregator.new

while($running) do
  aggregator.aggregate
  sleep config['sleep_time']
end
