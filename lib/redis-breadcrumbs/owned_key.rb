module Breadcrumbs
  class OwnedKey < Key
    def specialize object
      OwnedKey.new specialize_from_template(@key_template, object)
    end

    def clean_cmd
      [:del, @key_template]
    end
  end

end
