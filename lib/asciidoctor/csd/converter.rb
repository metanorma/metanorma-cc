require "asciidoctor"
require "asciidoctor/csd/version"
require "asciidoctor/csd/csdconvert"
require "asciidoctor/iso/converter"

module Asciidoctor
  module Csd
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class Converter < ISO::Converter

      register_for "csd"

      def metadata_author(node, xml)
        xml.creator **{ role: "author" } do |a|
          a.technical_committee node.attr("technical-committee"),
            **attr_code(type: node.attr("technical-committee-type"))
        end
      end

      def title(node, xml)
        ["en"].each do |lang|
          xml.title **{ language: lang } do |t|
            t << node.attr("title") 
          end
        end
      end

      def metadata_status(node, xml)
        xml.status { |s| s << node.attr("status") }
      end

      def metadata_id(node, xml)
        xml.id { |i| i << node.attr("docnumber") }
      end

      def metadata_copyright(node, xml)
        from = node.attr("copyright-year") || Date.today.year
        xml.copyright do |c|
          c.from from
          c.owner do |o|
            o.affiliation "CalConnect"
          end
        end
      end

      def title_validate(root)
        nil
      end

      def makexml(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<csd-standard>"]
        @@draft = node.attributes.has_key?("draft")
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</csd-standard>"
        result = textcleanup(result.flatten * "\n")
        ret1 = cleanup(Nokogiri::XML(result))
        ret1.root.add_namespace(nil, "http://riboseinc.com/isoxml")
        ret1
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(doc, "csd.rng")
      end

      def document(node)
        ret1 = makexml(node)
        validate(ret1)
        ret = ret1.to_xml(indent: 2)
        filename = node.attr("docfile").gsub(/\.adoc/, ".xml").
          gsub(%r{^.*/}, '')
        File.open("#{filename}", "w") { |f| f.write(ret) }
        CsdConvert.convert filename
        ret
      end


    end
  end
end
