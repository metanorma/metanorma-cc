require "metanorma"
require "metanorma-generic"
require_relative "./cc/processor"

module Metanorma
  module Cc
    class Configuration < Metanorma::Generic::Configuration
      def initialize(*args)
        super
      end
    end

    class << self
      extend Forwardable

      attr_accessor :configuration

      Configuration::CONFIG_ATTRS.each do |attr_name|
        def_delegator :@configuration, attr_name
      end

      def configure
        self.configuration ||= Configuration.new
        yield(configuration)
      end
    end

    configure {}
  end
end
Metanorma::Registry.instance.register(Metanorma::Cc::Processor)

