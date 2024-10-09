module IsoDoc
  module Cc
    class I18n < IsoDoc::Generic::I18n
      def configuration
        Metanorma::Cc.configuration
      end
    end
  end
end
