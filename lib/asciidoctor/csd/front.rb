require "asciidoctor"
require "asciidoctor/standoc/converter"
require "fileutils"

module Asciidoctor
  module Csd

    class Converter < Standoc::Converter

      def metadata_author(node, xml)
        xml.contributor do |c|
          c.role **{ type: "author" }
          c.organization do |a|
            a.name "CalConnect"
          end
        end
        personal_author(node, xml)
      end

      def personal_author(node, xml)
        if node.attr("fullname") || node.attr("surname")
          personal_author1(node, xml, "")
        end
        i = 2
        while node.attr("fullname_#{i}") || node.attr("surname_#{i}")
          personal_author1(node, xml, "_#{i}")
          i += 1
        end
      end

      def personal_author1(node, xml, suffix)
        xml.contributor do |c|
          c.role **{ type: node.attr("role#{suffix}").downcase || "author" }
          c.person do |p|
            p.name do |n|
              if node.attr("fullname#{suffix}")
                n.completename node.attr("fullname#{suffix}")
              else
                n.forename node.attr("givenname#{suffix}")
                n.surname node.attr("surname#{suffix}")
              end
            end
          end
        end
      end

      def metadata_publisher(node, xml)
        xml.contributor do |c|
          c.role **{ type: "publisher" }
          c.organization do |a|
            a.name "CalConnect"
          end
        end
      end

      def metadata_committee(node, xml)
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
        unless status && ::Metanorma::Csd::DOCSTATUS.keys.include?(status)
          warn "#{status} is not a legal status"
        end
        xml.status(**{ format: "plain" }) { |s| s << status }
      end

      def prefix_id(node)
        prefix = "CC"
        typesuffix = ::Metanorma::Csd::DOCSUFFIX[node.attr("doctype")] || ""
        prefix += "/#{typesuffix}" unless typesuffix.empty?
        status = ::Metanorma::Csd::DOCSTATUS[node.attr("status")] || ""
        prefix += "/#{status}" unless status.empty?
        prefix
      end

      def metadata_id(node, xml)
        id = node.attr("docnumber") || "???"
        prefix = prefix_id(node)
        id = "#{prefix} #{id}"
        year = node.attr("copyright-year")
        id += ":#{year}" if year
        xml.docidentifier id, **{type: "csd"}
        xml.docnumber node.attr("docnumber")
      end

      def doctype(node)
        d = node.attr("doctype")
        unless ::Metanorma::Csd::DOCSUFFIX.keys.include?(d)
          warn "#{d} is not a legal document type: reverting to 'standard'"
          d = "standard"
        end
        d
      end

      def metadata_copyright(node, xml)
        from = node.attr("copyright-year") || Date.today.year
        xml.copyright do |c|
          c.from from
          c.owner do |owner|
            owner.organization do |o|
              o.name "CalConnect"
            end
          end
        end
      end
    end
  end
end
