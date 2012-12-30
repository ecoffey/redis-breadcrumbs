module Breadcrumbs
  class MemberOfSetKey < Key
    def initialize member_template, set_template, clean_method
      @member_template = member_template.to_s
      @set_template = set_template.to_s
      @clean_method = clean_method
    end

    def specialize object
      MemberOfSetKey.new(
        specialize_from_template(@member_template, object),
        specialize_from_template(@set_template, object),
        @clean_method
      )
    end

    def clean_cmd
      [@clean_method, @set_template, @member_template]
    end
  end

end
