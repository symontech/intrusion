require 'rubygems'  
require 'rake'  
require 'echoe'  
  
Echoe.new('intrusion', '0.1.0') do |p|  
  p.description     = "intrusion detection for rails apps"
  p.url             = "http://github.com/symontech/intrusion"  
  p.author          = "Simon Wepfer"  
  p.email           = "sw@netsense.ch"  
  p.ignore_pattern  = ["tmp/*", "script/*"]  
  p.development_dependencies = []  
end  
  
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext } 
