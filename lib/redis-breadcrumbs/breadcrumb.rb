require 'redis-breadcrumbs/dsl'
require 'redis-breadcrumbs/keys'

class Redis
  class Breadcrumb
    include Breadcrumbs::Dsl

    attr_reader :tracked_in

    def initialize object
      @tracked_in = self.class.tracked_in_key.specialize(object).to_s
      @keys = self.class.keys.specialize object
    end

    def track!
      return if @tracked_in.nil? || @tracked_in == ""

      track_clean_commands
    end

    def clean!
      cmds = Set.new tracked_keys.concat(@keys.clean_cmds)

      cmds.each do |cmd_tuple|
        cmd = cmd_tuple[0]
        args = cmd_tuple[1..-1]
        redis.send cmd, *args
      end
    end

    def tracked_keys
      redis.smembers(@tracked_in).map do |json|
        JSON.parse(json)
      end
    end

    private

    def track_clean_commands
      jsons = @keys.clean_cmds.map(&:to_json)

      redis.sadd @tracked_in, jsons
    end

    def redis
      self.class.redis
    end

  end
end
