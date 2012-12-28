require 'test_helper'

describe 'Redis::Breadcrumb' do
  before do
    Redis::Breadcrumb.redis = MockRedis.new
  end

  it 'can register owned keys for a specific object' do
    class OwnedBreadcrumb < Redis::Breadcrumb
      tracked_in 'widget:<id>:tracking'

      owns 'widget:<id>'    
    end

    obj = Object.new
    class << obj
      def id; "foo"; end
    end

    breadcrumb = OwnedBreadcrumb.register(obj)

    assert_equal [["del", "widget:foo"]], breadcrumb.tracked_keys
  end

  it 'can register member of set keys for a specific object' do
    class MemberOfSetBreadcrumb < Redis::Breadcrumb
      tracked_in 'widget:<id>:tracking'

      member_of_set "<id>" => :a_set_of_things
    end

    obj = Object.new
    class << obj
      def id; "foo"; end
    end

    breadcrumb = MemberOfSetBreadcrumb.register(obj)

    assert_equal [["srem", "a_set_of_things", "foo"]], breadcrumb.tracked_keys
  end
end
