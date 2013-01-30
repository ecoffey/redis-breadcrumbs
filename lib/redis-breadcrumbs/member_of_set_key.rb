module Breadcrumbs
  class MemberOfSetKey < Key
    def initialize member_template, set_template, clean_method, options
      @options = options || {}
      @member_template = member_template
      @set_template = set_template
      @clean_method = clean_method
      @resetable = options[:reset]
    end

    def specialize object
      MemberOfSetKey.new(
        specialize_from_template(@member_template, object),
        specialize_from_template(@set_template, object),
        @clean_method,
        @options
      )
    end

    def clean_cmd
      [@clean_method, @set_template, @member_template]
    end

    def reset_cmd
      clean_cmd if @resetable
    end

    def key_name
      @set_template
    end
  end

end
