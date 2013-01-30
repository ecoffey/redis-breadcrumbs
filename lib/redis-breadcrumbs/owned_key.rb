module Breadcrumbs
  class OwnedKey < Key
    def initialize key_template, options
      @options = options || {}
      @key_template = key_template
      @resetable = options[:reset]
    end

    def specialize object
      OwnedKey.new specialize_from_template(@key_template, object), @options
    end

    def clean_cmd
      [:del, @key_template]
    end

    def reset_cmd
      clean_cmd if @resetable
    end

    def key_name
      @key_template
    end
  end

end
