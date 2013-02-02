require 'redis-breadcrumbs/keys'

module Breadcrumbs
  module Dsl

    def self.included subclass
      subclass.extend ClassMethods
    end

    module ClassMethods
      def redis
        @@redis
      end

      def redis= redis
        if defined?(Redis::Namespace) && redis.is_a?(Redis::Namespace)
          redis = redis.redis # yo dawg
        end

        @@redis = redis
      end

      def tracked_in *args
        args.length > 0 ? @tracked_in = args[0] : @tracked_in
      end

      def tracked_in_key
        Key.new tracked_in
      end

      def owns key_template, options={}
        owned_keys << key_template
        as = options.delete(:as)
        key = OwnedKey.new key_template, options
        keys[key_template] = OwnedKey.new(key_template, options)

        create_as_method key_template, as unless as.nil?
      end

      def member_of_set options
        add_member_of_set options, member_of_sets, :srem
      end

      def member_of_sorted_set options
        add_member_of_set options, member_of_sorted_sets, :zrem
      end

      alias :member_of_zset :member_of_sorted_set

      def tracked_keys
        redis.smembers(@tracked_in).map do |json|
          JSON.parse(json)
        end
      end

      def keys
        @keys ||= Keys.new
      end

      def owned_keys
        @owned_keys ||= []
      end

      def member_of_sets
        @member_of_sets ||= []
      end

      def member_of_sorted_sets
        @member_of_sorted_sets ||= []
      end

      private

      def add_member_of_set options, specific_keys, clean_cmd
        member_to_set = Hash[[options.to_a.shift]]

        member = member_to_set.keys[0]
        set = member_to_set[member]

        specific_keys << [member, set]
        keys[set] = MemberOfSetKey.new(member, set, clean_cmd, options)
      end

    end

  end
end
