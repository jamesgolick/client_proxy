$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'client_proxy'
require 'spec'
require 'spec/autorun'
require 'bourne'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
