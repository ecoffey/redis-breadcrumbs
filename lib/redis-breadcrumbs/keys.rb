require 'redis-breadcrumbs/key'
require 'redis-breadcrumbs/owned_key'
require 'redis-breadcrumbs/member_of_set_key'

module Breadcrumbs
  class Keys
    def initialize keys={}
      @keys = keys
    end

    def [] key_template
      @keys[key_template]
    end

    def []= key_template, key
      @keys[key_template] = key
    end

    def specialize object
      Keys.new(Hash[@keys.map do |(key_template, key)|
        [key_template, key.specialize(object)]
      end])
    end

    def clean_cmds
      @keys.values.map &:clean_cmd
    end

    def reset_cmds
      @keys.values.map(&:reset_cmd).compact
    end
  end

end
