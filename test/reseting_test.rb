require 'test_helper'

describe 'Redis::Breadcrumb' do
  before do
    Redis::Breadcrumb.redis = MockRedis.new
  end

  it 'by default resets owned key with clean command' do
    class ResetWithClean < Redis::Breadcrumb
      owns :a_key, :reset => true
    end

    ResetWithClean.redis.set 'a_key', 'hello'

    ResetWithClean.reset!

    assert_nil ResetWithClean.redis.get('a_key')
  end
end
