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
end
