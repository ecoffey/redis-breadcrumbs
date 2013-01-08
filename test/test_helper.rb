require 'rubygems'
require 'bundler/setup'
require 'mock_redis'
require 'mock_redis/version'
require 'minitest/autorun'

require 'redis-breadcrumbs'

puts "mock_redis: #{MockRedis::VERSION}"
