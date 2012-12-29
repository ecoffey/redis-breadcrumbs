require 'redis-breadcrumbs/dsl'

module Redis
  class Breadcrumb
    include Breadcrumbs::Dsl

    attr_reader :tracked_in, :owned_keys

    def initialize object
      specialize_with object
    end

    def track
      track_owned_keys
      track_member_of_set_keys
    end

    def tracked_keys
      redis.smembers(@tracked_in).map do |json|
        JSON.parse(json)
      end
    end

    private

    def track_owned_keys
      jsons = @owned_keys.map do |owned_key|
        [:del, owned_key].to_json
      end

      unless jsons.empty?
        redis.sadd @tracked_in, jsons
      end
    end

    def track_member_of_set_keys
      jsons = @member_of_set_keys.map do |member_of_set_key|
        [:srem, member_of_set_key[:set], member_of_set_key[:member]].to_json
      end

      unless jsons.empty?
        redis.sadd @tracked_in, jsons
      end
    end

    def redis
      self.class.redis
    end

    def specialize_with object
      tracked_in_template = self.class.tracked_in

      @tracked_in = specialize_from_template tracked_in_template, object
      specialize_owned_keys object
      specialize_member_of_set_keys object
    end

    def specialize_owned_keys object
      @owned_keys = self.class.owned_keys.map do |owned_key_template|
        specialize_from_template owned_key_template, object
      end
    end

    def specialize_member_of_set_keys object
      @member_of_set_keys = self.class.member_of_sets.map do |member_of_set_template|
        member = specialize_from_template member_of_set_template[0], object
        { :member => member, :set => member_of_set_template[1] }
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
