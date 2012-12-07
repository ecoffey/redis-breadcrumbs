require 'test_helper'

describe 'Redis::Breadcrumb' do
  it 'can record a key to track in' do
    class TestBreadcrumb < Redis::Breadcrumb
      tracked_in 'tracking_key'
    end
    assert_equal 'tracking_key', TestBreadcrumb.tracked_in
  end
end

