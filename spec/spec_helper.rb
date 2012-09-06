require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'rspec'
require 'rubygems'
require 'bundler/setup'

require 'trackinator'

RSpec.configure do |config|
  # some (optional) config here
end

