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
end
