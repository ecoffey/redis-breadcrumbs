require 'test_helper'

describe 'Redis::Breadcrumb' do
  before do
    Redis::Breadcrumb.redis = MockRedis.new
  end

  it 'can access as methods directly from the breadcrumb' do
    class DirectAsMethod < Redis::Breadcrumb
      owns :a_key, :as => :my_key
    end

    DirectAsMethod.my_key.set 'hello'

    assert_equal 'hello', DirectAsMethod.redis.get('a_key')
  end

  it 'can create a method to access the key through' do
    class OwnedAsMethod < Redis::Breadcrumb
      owns :a_key, :as => :my_key
    end

    OwnedAsMethod.new.my_key.set 'hello'

    assert_equal 'hello', OwnedAsMethod.redis.get('a_key')
  end
end
