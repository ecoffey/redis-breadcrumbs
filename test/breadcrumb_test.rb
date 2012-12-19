require 'test_helper'

describe 'Redis::Breadcrumb' do
  class TestBreadcrumb < Redis::Breadcrumb
    tracked_in 'tracking_key'

    owns :a_owned_key
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

  it 'will register tracked keys in tracked_in' do
    TestBreadcrumb.register

    assert_equal 1, Redis::Breadcrumb.redis.scard(TestBreadcrumb.tracked_in)
    assert_equal [["del", "a_owned_key"]], TestBreadcrumb.tracked_keys
  end

  it 'tracks keys for each class' do
    class Test2Breadcrumb < Redis::Breadcrumb
      tracked_in 'different_tracking_key'

      owns :a_different_key
    end

    refute_equal TestBreadcrumb.owned_keys, Test2Breadcrumb.owned_keys
  end
end
