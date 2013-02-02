require 'redis-breadcrumbs/dsl'
require 'redis-breadcrumbs/as_methods'
require 'redis-breadcrumbs/entrance'
require 'redis-breadcrumbs/keys'
require 'redis-breadcrumbs/unspecialized_dummy_object'

class Redis
  class Breadcrumb
    include Breadcrumbs::Dsl
    include Breadcrumbs::AsMethods
    include Breadcrumbs::Entrance

    class << self
      def method_missing mthd, *args
        new.send(mthd)
      end
    end

    attr_reader :tracked_in

    def initialize object=Breadcrumbs::UnspecializedDummyObject.new
      @tracked_in = self.class.tracked_in_key.specialize(object).to_s
      @keys = self.class.keys.specialize object
    end

    def track!
      return if @tracked_in.nil? || @tracked_in == ""

      jsons = @keys.clean_cmds.map(&:to_json)

      redis.sadd @tracked_in, jsons
    end

    def reset!
      run_cmds @keys.reset_cmds
    end

    def clean!
      run_cmds Set.new(tracked_keys.concat(@keys.clean_cmds))
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

    def run_cmds cmds
      cmds.each do |cmd_tuple|
        cmd = cmd_tuple[0]
        args = cmd_tuple[1..-1]
        redis.send cmd, *args
      end
    end

  end
end
