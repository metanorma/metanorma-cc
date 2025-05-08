require "metanorma/processor"

module Metanorma
  module Cc
    class Processor < Metanorma::Generic::Processor
      def configuration
        Metanorma::Cc.configuration
      end

      def initialize
        @short = %i[csd cc]
        @input_format = :asciidoc
        @asciidoctor_backend = :cc
      end

      def output_formats
        super.merge(
          html: "html",
          pdf: "pdf",
          doc: "doc",
        )
      end

      def version
        "Metanorma::Cc #{Metanorma::Cc::VERSION}"
      end

      def output(isodoc_node, inname, outname, format, options = {})
        options_preprocess(options)
        case format
        when :html
          IsoDoc::Cc::HtmlConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::Cc::WordConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::Cc::PdfConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::Cc::PresentationXMLConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
