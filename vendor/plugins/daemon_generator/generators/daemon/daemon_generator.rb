require 'rails/generators'

class DaemonGenerator < Rails::Generators::Base
  def manifest
    record do |m|
      m.directory "lib/daemons"
      m.directory "config/daemons"
      m.file "daemons", "script/daemons", :chmod => 0755
      m.template "script.yml", "config/daemons/#{file_name}.yml"
      m.template "script.rb", "lib/daemons/#{file_name}.rb", :chmod => 0755
      m.template "script_ctl", "lib/daemons/#{file_name}_ctl", :chmod => 0755
      m.file "daemons.yml", "config/daemons.yml"
    end
  end
end
