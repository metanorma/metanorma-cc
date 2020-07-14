require "asciidoctor"
require "isodoc/cc/html_convert"
require "isodoc/cc/word_convert"
require "isodoc/cc/presentation_xml_convert"
require "metanorma/cc"
require "asciidoctor/standoc/converter"
require "fileutils"
require_relative "validate"
require_relative "validate_section"
require_relative "front"

module Asciidoctor
  module CC

    # A {Converter} implementation that generates CC output, and a document
    # schema encapsulation of the document for validation
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "csd-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/csd".freeze

      register_for "cc"

      def initialize(backend, opts)
        super
      end

      def outputs(node, ret)
         File.open(@filename + ".xml", "w:UTF-8") { |f| f.write(ret) }
          presentation_xml_converter(node).convert(@filename + ".xml")
          html_converter(node).convert(@filename + ".presentation.xml", 
                                       nil, false, "#{@filename}.html")
          doc_converter(node).convert(@filename + ".presentation.xml", 
                                      nil, false, "#{@filename}.doc")
          pdf_converter(node)&.convert(@filename + ".presentation.xml", 
                                       nil, false, "#{@filename}.pdf")
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "cc.rng"))
      end

      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def style(n, t)
        return
      end

      def html_converter(node)
        IsoDoc::CC::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        IsoDoc::CC::PdfConvert.new(html_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::CC::WordConvert.new(doc_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        IsoDoc::CC::PresentationXMLConvert.new(doc_extract_attributes(node))
      end
    end
  end
end
