require "isodoc"

module IsoDoc
  module Cc
    module BaseConvert
      def configuration
        Metanorma::Cc.configuration
      end
    end
  end
end
