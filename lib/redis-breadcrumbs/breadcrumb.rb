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
  end
end
