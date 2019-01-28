require "asciidoctor"
require "isodoc/csd/html_convert"
require "isodoc/csd/word_convert"
require "metanorma/csd"
require "asciidoctor/standoc/converter"
require "fileutils"
require_relative "validate_section"
require_relative "front"

module Asciidoctor
  module Csd
    CSD_NAMESPACE = "https://www.calconnect.org/standards/csd"

    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class Converter < Standoc::Converter

      register_for "csd"

      def initialize(backend, opts)
        super
      end

      def makexml(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<csd-standard>"]
        @draft = node.attributes.has_key?("draft")
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</csd-standard>"
        result = textcleanup(result)
        ret1 = cleanup(Nokogiri::XML(result))
        validate(ret1)
        ret1.root.add_namespace(nil, CSD_NAMESPACE)
        ret1
      end

      def document(node)
        init(node)
        ret1 = makexml(node)
        ret = ret1.to_xml(indent: 2)
        unless node.attr("nodoc") || !node.attr("docfile")
          filename = node.attr("docfile").gsub(/\.adoc$/, ".xml").
            gsub(%r{^.*/}, "")
          File.open(filename, "w") { |f| f.write(ret) }
          html_converter(node).convert filename
          word_converter(node).convert filename
          pdf_converter(node).convert filename
        end
        @files_to_delete.each { |f| FileUtils.rm f }
        ret
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "csd.rng"))
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
        IsoDoc::Csd::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        IsoDoc::Csd::PdfConvert.new(html_extract_attributes(node))
      end

      def word_converter(node)
        IsoDoc::Csd::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end
