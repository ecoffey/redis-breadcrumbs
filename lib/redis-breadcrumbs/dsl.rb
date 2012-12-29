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
        @@redis = redis
      end

      def tracked_in *args
        args.length > 0 ? @tracked_in = args[0] : @tracked_in
      end

      def owns key
        owned_keys << key
      end

      def member_of_set member_to_set
        member = member_to_set.keys[0]
        set = member_to_set[member]

        member_of_sets << [member, set]
      end

      def track object=UnspecializedDummyObject.new
        new(object).tap(&:track)
      end

      def tracked_keys
        redis.smembers(@tracked_in).map do |json|
          JSON.parse(json)
        end
      end

      def owned_keys
        @owned_keys ||= []
      end

      def member_of_sets
        @member_of_sets ||= []
      end
    end

  end
end
