module Metanorma
  module Cc
    class Cleanup < Metanorma::Generic::Cleanup
      extend Forwardable

      def_delegators :@converter, *delegator_methods

    end
  end
end
