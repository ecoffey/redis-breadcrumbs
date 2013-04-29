require 'test_helper'

describe 'Redis::Breadcrumb' do
  before do
    Redis::Breadcrumb.redis = MockRedis.new
  end

  it 'will clean up currently defined keys' do
    class CleanUpCurrentKeys < Redis::Breadcrumb
      owns :a_key
    end

    CleanUpCurrentKeys.redis.set 'a_key', 'hello'

    assert_equal 'hello', CleanUpCurrentKeys.redis.get('a_key')

    CleanUpCurrentKeys.clean!

    assert_nil CleanUpCurrentKeys.redis.get('a_key')
  end

  it 'will raise if no object given for specialized template' do
    class UnspecializedCleanKeys < Redis::Breadcrumb
      owns 'widget:<id>'
    end

    assert_raises BreadcrumbSpecializationError do
      UnspecializedCleanKeys.clean!
    end
  end

  it 'will clean up currently defined specialized keys' do
    class CleanUpCurrentSpecializedKeys < Redis::Breadcrumb
      owns 'widget:<id>'
    end

    obj = Object.new
    class << obj
      def id; 'foo'; end
    end

    CleanUpCurrentSpecializedKeys.redis.set 'widget:foo', 'yarg'

    assert_equal 'yarg', CleanUpCurrentSpecializedKeys.redis.get('widget:foo')

    CleanUpCurrentSpecializedKeys.clean! obj

    assert_nil CleanUpCurrentSpecializedKeys.redis.get('widget:foo')
  end

  it 'will clean up previously tracked and current keys' do
    class CleanUpPrevAndCurrentKeys < Redis::Breadcrumb
      tracked_in 'widget:<id>:tracking'

      owns 'widget:<id>'

      member_of_set '<id>' => 'widgets'
    end

    obj = Object.new
    class << obj
      def id; 'foo'; end
    end

    CleanUpPrevAndCurrentKeys.redis.sadd 'widget:foo:tracking', [:del, 'widget:foo:blah'].to_json

    CleanUpPrevAndCurrentKeys.redis.set 'widget:foo', 'hello'
    CleanUpPrevAndCurrentKeys.redis.set 'widget:foo:blah', 'world'
    CleanUpPrevAndCurrentKeys.redis.sadd 'widgets', 'foo'

    CleanUpPrevAndCurrentKeys.clean! obj

    assert_nil CleanUpPrevAndCurrentKeys.redis.get('widget:foo')
    assert_nil CleanUpPrevAndCurrentKeys.redis.get('widget:foo:blah')
    refute CleanUpPrevAndCurrentKeys.redis.sismember('widgets', 'foo')
  end
end
