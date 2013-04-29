require 'test_helper'

describe 'Redis::Breadcrumb' do
  class DslBreadcrumb < Redis::Breadcrumb
    tracked_in 'tracking_key'

    owns :a_owned_key

    member_of_set :id => :a_set_of_things
    member_of_zset :id => :a_sorted_set_of_things
  end

  before do
    redis = MockRedis.new

    Redis::Breadcrumb.redis = redis
  end

  it 'will unwrap a RedisNamespace to the "raw" client' do
    require 'redis-namespace'

    redis = MockRedis.new
    rn = Redis::Namespace.new :namespaced, :redis => redis

    Redis::Breadcrumb.redis = rn

    Redis::Breadcrumb.redis.set 'blah', 1

    assert_nil redis.get('namespaced:blah')
    assert_equal "1", redis.get('blah')
  end

  it 'can record a key to track in' do
    assert_equal 'tracking_key', DslBreadcrumb.tracked_in
  end

  it 'can own a key' do
    assert_equal [:a_owned_key], DslBreadcrumb.owned_keys
  end

  it 'can be a member of a set' do
    assert_equal [[:id, :a_set_of_things]], DslBreadcrumb.member_of_sets
  end

  it 'can be a member of a sorted set' do
    assert_equal [[:id, :a_sorted_set_of_things]], DslBreadcrumb.member_of_sorted_sets
  end

  it 'tracks keys for each class' do
    class Test2Breadcrumb < Redis::Breadcrumb
      tracked_in 'different_tracking_key'

      owns :a_different_key
    end

    refute_equal DslBreadcrumb.owned_keys, Test2Breadcrumb.owned_keys
  end

end
