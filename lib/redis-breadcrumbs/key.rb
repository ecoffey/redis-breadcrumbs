module Breadcrumbs
  class Key
    def initialize key_template
      @key_template = key_template.to_s
    end

    def specialize object
      Key.new specialize_from_template(@key_template, object)
    end

    def clean_cmd
      raise "Can't clean this key #{@key_template}"
    end

    def to_s
      @key_template
    end

    protected

    TEMPLATE_REGEX = /(<\w+>)/

    def specialize_from_template template, object
      matches = TEMPLATE_REGEX.match template.to_s

      return template if matches.nil?

      specialized = template.dup

      matches.captures.each do |method_marker|
        method = method_marker[1..-2].to_sym

        specialized.gsub! method_marker, object.send(method)
      end

      specialized
    end
  end

end
