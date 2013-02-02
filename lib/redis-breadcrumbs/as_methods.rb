require 'redis-breadcrumbs/key_proxy'

module Breadcrumbs
  module AsMethods

    def self.included subclass
      subclass.extend ClassMethods
    end

    module ClassMethods
      def create_as_method key_template, as
        instance_eval do
          define_method as.to_sym do
            KeyProxy.new(self.class.keys[key_template], redis)
          end
        end
      end
    end
  end
end
