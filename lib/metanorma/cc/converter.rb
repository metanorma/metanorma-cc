require "asciidoctor"
require "isodoc/cc/html_convert"
require "isodoc/cc/word_convert"
require "isodoc/cc/presentation_xml_convert"
require "metanorma/cc"
require "metanorma/standoc/converter"
require "metanorma/generic/converter"
require_relative "validate_section"

module Metanorma
  module Cc
    class Converter < Metanorma::Generic::Converter
      register_for "cc"

      def configuration
        Metanorma::Cc.configuration
      end

      def outputs(node, ret)
        File.open("#{@filename}.xml", "w:UTF-8") { |f| f.write(ret) }
        presentation_xml_converter(node).convert("#{@filename}.xml")
        html_converter(node).convert("#{@filename}.presentation.xml",
                                     nil, false, "#{@filename}.html")
        doc_converter(node).convert("#{@filename}.presentation.xml",
                                    nil, false, "#{@filename}.doc")
        pdf_converter(node)&.convert("#{@filename}.presentation.xml",
                                     nil, false, "#{@filename}.pdf")
      end

      def html_converter(node)
        IsoDoc::Cc::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        return if node.attr("no-pdf")

        IsoDoc::Cc::PdfConvert.new(pdf_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::Cc::WordConvert.new(doc_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        IsoDoc::Cc::PresentationXMLConvert
          .new(doc_extract_attributes(node)
          .merge(output_formats: ::Metanorma::Cc::Processor.new.output_formats))
      end
    end
  end
end

require_relative "log"
