require "metanorma/processor"

module Metanorma
  module Csd
    class Processor < Metanorma::Processor

      def initialize
        @short = :csd
        @input_format = :asciidoc
        @asciidoctor_backend = :csd
      end

      def output_formats
        super.merge(
          html: "html",
          pdf: "pdf",
          doc: "doc"
        )
      end

      def version
        "Asciidoctor::Csd #{Asciidoctor::Csd::VERSION}"
      end

      def input_to_isodoc(file)
        Metanorma::Input::Asciidoc.new.process(file, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Csd::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Csd::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Csd::PdfConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end
    end
  end
end
