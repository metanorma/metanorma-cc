require "isodoc"

module IsoDoc
  module CC
    module BaseConvert
      def configuration
        Metanorma::CC.configuration
      end
    end
  end
end
