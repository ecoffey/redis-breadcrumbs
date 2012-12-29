require 'test_helper'

describe 'Redis::Breadcrumb' do
  before do
    Redis::Breadcrumb.redis = MockRedis.new
  end

  it 'can track tracked keys in tracked_in' do
    class TrackedInBreadcrumb < Redis::Breadcrumb
      tracked_in 'tracking_key'

      owns :a_owned_key

      member_of_set :id => :a_set_of_things
    end

    TrackedInBreadcrumb.track

    assert_equal [
      ["srem", "a_set_of_things", "id"],
      ["del", "a_owned_key"]
    ].sort, TrackedInBreadcrumb.tracked_keys.sort
  end

  it 'tracked_in can be optional' do
    class NoTrackedInBreadcrumb < Redis::Breadcrumb
      owns :a_key
    end

    NoTrackedInBreadcrumb.track

    assert_equal [], NoTrackedInBreadcrumb.redis.keys('*')
  end

  it 'will raise if no object given for specialized template' do
    class UnspecializedBreadcrumb < Redis::Breadcrumb
      tracked_in 'tracking_key'

      owns 'a_special_<id>_key'
    end

    assert_raises BreadcrumbSpecializationError do
      UnspecializedBreadcrumb.track
    end
  end

  it 'can track owned keys for a specific object' do
    class OwnedBreadcrumb < Redis::Breadcrumb
      tracked_in 'widget:<id>:tracking'

      owns 'widget:<id>'    
    end

    obj = Object.new
    class << obj
      def id; "foo"; end
    end

    breadcrumb = OwnedBreadcrumb.track(obj)

    assert_equal [["del", "widget:foo"]], breadcrumb.tracked_keys
  end

  it 'can track member of set keys for a specific object' do
    class MemberOfSetBreadcrumb < Redis::Breadcrumb
      tracked_in 'widget:<id>:tracking'

      member_of_set "<id>" => :a_set_of_things
    end

    obj = Object.new
    class << obj
      def id; "foo"; end
    end

    breadcrumb = MemberOfSetBreadcrumb.track(obj)

    assert_equal [["srem", "a_set_of_things", "foo"]], breadcrumb.tracked_keys
  end
end
