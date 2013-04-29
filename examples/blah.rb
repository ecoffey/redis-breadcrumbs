class BlahBreadcrumb < Redis::Breadcrumb
  owns 'blah:<id>'
  member_of_set '<id>' => 'blahs'
end

class Blah
  def initialize(n)
    @n = n
  end

  def id; @n.to_s; end
end
