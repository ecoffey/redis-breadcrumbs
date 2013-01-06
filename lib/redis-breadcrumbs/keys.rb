require 'redis-breadcrumbs/key'
require 'redis-breadcrumbs/owned_key'
require 'redis-breadcrumbs/member_of_set_key'

module Breadcrumbs
  class Keys
    def initialize keys=[]
      @keys = keys
    end

    def << key
      @keys << key
    end

    def specialize object
      Keys.new(@keys.map do |key|
        key.specialize object
      end)
    end

    def clean_cmds
      @keys.map &:clean_cmd
    end

    def reset_cmds
      @keys.map(&:reset_cmd).compact
    end
  end

end
