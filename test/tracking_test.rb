require 'test_helper'

describe 'Redis::Breadcrumb' do
  before do
    Redis::Breadcrumb.redis = MockRedis.new
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
