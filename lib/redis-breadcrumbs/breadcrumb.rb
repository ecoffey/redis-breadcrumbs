module Redis
  class Breadcrumb
    class << self
      def tracked_in *args
        args.length > 0 ? @tracked_in = args[0] : @tracked_in
      end
    end
  end
end
