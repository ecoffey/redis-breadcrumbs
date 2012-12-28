require 'test_helper'

describe 'Redis::Breadcrumb' do
  class TestBreadcrumb < Redis::Breadcrumb
    tracked_in 'tracking_key'

    owns :a_owned_key

    member_of_set :id => :a_set_of_things
  end

  before do
    redis = MockRedis.new

    Redis::Breadcrumb.redis = redis
  end

  it 'can record a key to track in' do
    assert_equal 'tracking_key', TestBreadcrumb.tracked_in
  end

  it 'can own a key' do
    assert_equal [:a_owned_key], TestBreadcrumb.owned_keys
  end

  it 'can be a member of a set' do
    assert_equal [[:id, :a_set_of_things]], TestBreadcrumb.member_of_sets
  end

  it 'will track tracked keys in tracked_in' do
    TestBreadcrumb.track

    assert_equal 2, Redis::Breadcrumb.redis.scard(TestBreadcrumb.tracked_in)
    assert_equal [
      ["srem", "a_set_of_things", "id"],
      ["del", "a_owned_key"]
    ].sort, TestBreadcrumb.tracked_keys.sort
  end

  it 'tracks keys for each class' do
    class Test2Breadcrumb < Redis::Breadcrumb
      tracked_in 'different_tracking_key'

      owns :a_different_key
    end

    refute_equal TestBreadcrumb.owned_keys, Test2Breadcrumb.owned_keys
  end

end
