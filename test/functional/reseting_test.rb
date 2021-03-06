require 'test_helper'

describe 'Redis::Breadcrumb' do
  before do
    Redis::Breadcrumb.redis = MockRedis.new
  end

  it 'by default resets owned key with clean command' do
    class OwnedResetWithClean < Redis::Breadcrumb
      owns :a_key, :reset => true
    end

    OwnedResetWithClean.redis.set 'a_key', 'hello'

    OwnedResetWithClean.reset!

    assert_nil OwnedResetWithClean.redis.get('a_key')
  end

  it 'by default resets member of set keys with clean command' do
    class MemberOfSetResetWithClean < Redis::Breadcrumb
      member_of_set :blah => :a_set, :reset => true
    end

    MemberOfSetResetWithClean.redis.sadd 'a_set', 'blah'

    assert_equal 1, MemberOfSetResetWithClean.redis.scard('a_set')
    assert MemberOfSetResetWithClean.redis.sismember 'a_set', 'blah'

    MemberOfSetResetWithClean.reset!

    assert_equal 0, MemberOfSetResetWithClean.redis.scard('a_set')
    refute MemberOfSetResetWithClean.redis.sismember 'a_set', 'blah'
  end

  it 'by default resets member of sorted set keys with clean command' do
    class MemberOfZsetResetWithClean < Redis::Breadcrumb
      member_of_zset :blah => :a_set, :reset => true
    end

    MemberOfZsetResetWithClean.redis.zadd 'a_set', 1, 'blah'

    assert_equal 1, MemberOfZsetResetWithClean.redis.zcard('a_set')
    assert MemberOfZsetResetWithClean.redis.zrank 'a_set', 'blah'

    MemberOfZsetResetWithClean.reset!

    assert_equal 0, MemberOfZsetResetWithClean.redis.zcard('a_set')
    refute MemberOfZsetResetWithClean.redis.zrank 'a_set', 'blah'
  end

end
