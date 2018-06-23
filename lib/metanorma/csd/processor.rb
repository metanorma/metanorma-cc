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
        {
          html: "html",
          pdf: "pdf"
        }
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
        when :pdf
          require 'tempfile'
          # Tempfile.open("#{outname}.html") do |tmp|
          outname_html = outname + ".html"
          IsoDoc::Csd::HtmlConvert.new(options).convert(outname_html, isodoc_node)
          puts outname_html
          system "cat #{outname_html}"
          Metanorma::Output::Pdf.new.convert(outname_html, outname)
        end

      end

    end
  end
end
