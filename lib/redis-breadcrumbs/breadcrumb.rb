module Redis
  class Breadcrumb
    class << self
      attr_accessor :owned_keys

      def tracked_in *args
        args.length > 0 ? @tracked_in = args[0] : @tracked_in
      end

      def owns key
        (@owned_keys ||= []) << key
      end
    end
  end
end
