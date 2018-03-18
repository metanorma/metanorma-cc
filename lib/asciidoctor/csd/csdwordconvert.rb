require "isodoc"
  
module Asciidoctor
  module Csd
    # A {Converter} implementation that generates Csd output, and a document
    # schema encapsulation of the document for validation

    class CsdWordConvert < CsdConvert
      include IsoDoc::WordConvertModule

      def initialize(options)
        super
      end
    end
  end
end

