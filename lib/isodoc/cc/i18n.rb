module IsoDoc
  module CC
    class I18n < IsoDoc::Generic::I18n
      def configuration
        Metanorma::CC.configuration
      end
    end
  end
end
