module Breadcrumbs
  class KeyProxy
    def initialize key, redis
      @key = key
      @redis = redis
    end

    def method_missing mthd, *args
      @redis.send(mthd, *([@key.key_name] + args))
    end
  end
end
