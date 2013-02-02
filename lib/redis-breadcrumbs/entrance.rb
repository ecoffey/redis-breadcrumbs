require 'redis-breadcrumbs/key_proxy'
require 'redis-breadcrumbs/unspecialized_dummy_object'

module Breadcrumbs
  module Entrance

    def self.included subclass
      subclass.extend ClassMethods
    end

    def self.included subclass
      subclass.extend ClassMethods
    end

    module ClassMethods
      def track! object=UnspecializedDummyObject.new
        new(object).tap(&:track!)
      end

      def reset! object=UnspecializedDummyObject.new
        new(object).tap(&:reset!)
      end

      def clean! object=UnspecializedDummyObject.new
        new(object).tap(&:clean!)
      end
    end
  end
end
