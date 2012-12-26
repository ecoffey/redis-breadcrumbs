require 'test_helper'

describe 'Redis::Breadcrumb' do
  before do
    redis = MockRedis.new

    Redis::Breadcrumb.redis = redis
  end

  it 'can specialize tracked_in key name' do
    class SpecializedBreadcrumb < Redis::Breadcrumb
      tracked_in 'widget:<id>'
    end

    obj = Object.new
    class << obj
      def id; "foo"; end
    end

    assert_equal 'widget:foo', SpecializedBreadcrumb.new(obj).tracked_in
  end

end

