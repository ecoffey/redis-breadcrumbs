class BreadcrumbSpecializationError < Exception; end

module Breadcrumbs
  class UnspecializedDummyObject
    instance_methods.each do |m|
      undef_method m unless m =~ /^(__|object_id|instance_eval)/
    end

    def method_missing method, *args
      raise BreadcrumbSpecializationError, "#{method}"
    end

    def respond_to? *args; false; end
  end
end
