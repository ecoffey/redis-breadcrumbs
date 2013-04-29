require 'test_helper'

describe 'Breadcrumbs::Key' do
  it 'can specialize on template methods that do not return a string' do
    key = Breadcrumbs::Key.new 'blah:<id>'

    o = Object.new
    def o.id; 42; end

    assert_equal "blah:42", key.specialize(o).to_s 
  end
end
