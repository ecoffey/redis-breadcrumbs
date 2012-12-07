require 'test_helper'

describe 'Redis::Breadcrumb' do
  class TestBreadcrumb < Redis::Breadcrumb
    tracked_in 'tracking_key'

    owns :a_owned_key
  end

  it 'can record a key to track in' do
    assert_equal 'tracking_key', TestBreadcrumb.tracked_in
  end

  it 'can own a key' do
    assert_equal [:a_owned_key], TestBreadcrumb.owned_keys
  end
end
