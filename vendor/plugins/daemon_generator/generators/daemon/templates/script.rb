#!/usr/bin/env ruby

require 'yaml'

# You might want to change this
ENV["RAILS_ENV"] ||= "production"
require File.dirname(__FILE__) + "/../../config/environment"

def load_config
  daemon_config = YAML::load(File.open("#{Rails.root}/config/daemons/<%=file_name%>.yml"))
  daemon_config = Hash[*daemon_config.to_a.collect { |key, value| [key.to_sym, eval(value)]}.flatten]
end

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  config = load_config

  # Replace this with your code
  ActiveRecord::Base.logger.info "This daemon is still running at #{Time.now}.\n"

  wake_up_time = Time.now + config[:sleep_time]
  sleep config[:sleep_time]
end
