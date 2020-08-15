require "asciidoctor"
require "asciidoctor/standoc/converter"
require "fileutils"

module Asciidoctor
  module CC
    class Converter < Standoc::Converter
      def default_publisher
        "CalConnect"
      end

      def metadata_committee(node, xml)
        return unless node.attr("technical-committee")
        xml.editorialgroup do |a|
          a.technical_committee node.attr("technical-committee"),
            **attr_code(type: node.attr("technical-committee-type"))
          i = 2
          while node.attr("technical-committee_#{i}") do
            a.technical_committee node.attr("technical-committee_#{i}"),
              **attr_code(type: node.attr("technical-committee-type_#{i}"))
            i += 1
          end
        end
      end

      def metadata_status(node, xml)
        status = node.attr("status")
        unless status && ::Metanorma::CC::DOCSTATUS.keys.include?(status)
          @log.add("Document Attributes", nil, "#{status} is not a legal status")
        end
        super
      end

      def prefix_id(node)
        prefix = "CC"
        typesuffix = ::Metanorma::CC::DOCSUFFIX[doctype(node)] || ""
        prefix += "/#{typesuffix}" unless typesuffix.empty?
        status = ::Metanorma::CC::DOCSTATUS[node.attr("status")] || ""
        prefix += "/#{status}" unless status.empty?
        prefix
      end

      def metadata_id(node, xml)
        id = node.attr("docnumber") || "???"
        prefix = prefix_id(node)
        id = "#{prefix} #{id}"
        year = node.attr("copyright-year")
        id += ":#{year}" if year
        xml.docidentifier id, **{type: "CalConnect"}
        xml.docnumber node.attr("docnumber")
      end

      @log_doctype = false

      def doctype(node)
        d = super
        unless ::Metanorma::CC::DOCSUFFIX.keys.include?(d) && !@log_doctype
          @log.add("Document Attributes", nil,
                   "#{d} is not a legal document type: reverting to 'standard'")
          @log_doctype = true
          d = "standard"
        end
        d
      end
    end
  end
end
