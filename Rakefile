require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('intrusion', '0.1.6') do |p|
  p.description     = 'intrusion detection and prevention for rails apps'
  p.url             = 'http://github.com/symontech/intrusion'
  p.author          = 'Simon Duncombe'
  p.email           = 'sd@netsense.ch'
  p.ignore_pattern  = ['tmp/*', 'script/*']
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
