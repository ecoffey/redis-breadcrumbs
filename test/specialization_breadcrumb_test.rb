require 'test_helper'

describe 'Redis::Breadcrumb' do
  class SpecializedBreadcrumb < Redis::Breadcrumb
    tracked_in 'widget:<id>:tracking'

    owns 'widget:<id>'
  end

  before do
    redis = MockRedis.new

    Redis::Breadcrumb.redis = redis
  end

  it 'can specialize tracked_in key name' do
    obj = Object.new
    class << obj
      def id; "foo"; end
    end

    assert_equal 'widget:foo:tracking', SpecializedBreadcrumb.new(obj).tracked_in
  end

  it 'can specialize owned key names' do
    obj = Object.new
    class << obj
      def id; "foo"; end
    end

    breadcrumb = SpecializedBreadcrumb.new obj

    assert_equal ['widget:foo'], breadcrumb.owned_keys
  end

end

