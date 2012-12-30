module Breadcrumbs
  class OwnedKey < Key
    def initialize key_template
      @key_template = key_template.to_s
    end

    def specialize object
      OwnedKey.new specialize_from_template(@key_template, object)
    end

    def clean_cmd
      [:del, @key_template]
    end
  end

end
