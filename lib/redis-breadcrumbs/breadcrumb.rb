module Redis
  class Breadcrumb
    class << self
      attr_accessor :owned_keys

      def redis
       @@redis
      end

      def redis= redis
        @@redis = redis
      end

      def tracked_in *args
        args.length > 0 ? @tracked_in = args[0] : @tracked_in
      end

      def owns key
        (@owned_keys ||= []) << key
      end

      def register
        @owned_keys.each do |key|
          redis.sadd @tracked_in, [:del, key].to_json
        end
      end

      def tracked_keys
        redis.smembers(@tracked_in).map do |json|
          JSON.parse(json)
        end
      end
    end

    attr_reader :tracked_in

    def initialize object
      specialize_with object
    end

    def specialize_with object
      tracked_in_template = self.class.tracked_in

      @tracked_in = specialize_from_template tracked_in_template, object
    end

    TEMPLATE_REGEX = /(<\w+>)/

    def specialize_from_template template, object
      matches = template.match TEMPLATE_REGEX

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
