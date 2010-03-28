#!/usr/bin/env ruby
# encoding: utf-8

require "yaml"
require "app/aggregators/aggregator"

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

ActiveRecord::Base.logger = nil
config = load_config
aggregator = Aggregator.new

while($running) do
  aggregator.aggregate
  sleep config['sleep_time']
end
