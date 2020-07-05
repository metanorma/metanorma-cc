require_relative "base_convert"
require "isodoc"

module IsoDoc
  module CC
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def pdf_stylesheet(docxml)
        "csd.standard.xsl"
      end
    end
  end
end

