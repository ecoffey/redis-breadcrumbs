module Redis
  class Breadcrumb
    class << self
      attr_accessor :owned_keys, :member_of_sets

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

      def member_of_set member_to_set
        member = member_to_set.keys[0]
        set = member_to_set[member]

        (@member_of_sets ||= []) << [member, set]
      end

      def register object=nil
        new(object).tap(&:register)
      end

      def tracked_keys
        redis.smembers(@tracked_in).map do |json|
          JSON.parse(json)
        end
      end
    end

    attr_reader :tracked_in, :owned_keys

    def initialize object
      specialize_with object
    end

    def register
      jsons = @owned_keys.map do |owned_key|
        [:del, owned_key].to_json
      end

      redis.sadd @tracked_in, jsons
    end

    def tracked_keys
      redis.smembers(@tracked_in).map do |json|
        JSON.parse(json)
      end
    end

    private

    def redis
      self.class.redis
    end

    def specialize_with object
      tracked_in_template = self.class.tracked_in

      @tracked_in = specialize_from_template tracked_in_template, object
      @owned_keys = self.class.owned_keys.map do |owned_key_template|
        specialize_from_template owned_key_template, object
      end
    end

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
