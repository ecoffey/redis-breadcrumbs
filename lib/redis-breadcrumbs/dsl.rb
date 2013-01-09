require 'redis-breadcrumbs/keys'

class BreadcrumbSpecializationError < Exception; end

module Breadcrumbs
  module Dsl

    class UnspecializedDummyObject
      instance_methods.each do |m|
        undef_method m unless m =~ /^(__|object_id|instance_eval)/
      end

      def method_missing method, *args
        raise BreadcrumbSpecializationError, "#{method}"
      end

      def respond_to? *args; false; end
    end

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

      def owns key, options={}
        owned_keys << key
        keys << OwnedKey.new(key, options)
      end

      def member_of_set options
        add_member_of_set options, member_of_sets, :srem
      end

      def member_of_sorted_set options
        add_member_of_set options, member_of_sorted_sets, :zrem
      end

      alias :member_of_zset :member_of_sorted_set

      def track! object=UnspecializedDummyObject.new
        new(object).tap(&:track!)
      end

      def reset! object=UnspecializedDummyObject.new
        new(object).tap(&:reset!)
      end

      def clean! object=UnspecializedDummyObject.new
        new(object).tap(&:clean!)
      end

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
        keys << MemberOfSetKey.new(member, set, clean_cmd, options)
      end
    end

  end
end
