require "asciidoctor"
require "asciidoctor/csd/version"
require "isodoc/csd/csdconvert"
require "asciidoctor/standoc/converter"

module Asciidoctor
  module Csd
    CSD_NAMESPACE = "https://www.calconnect.org/standards/csd"

    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class Converter < Standoc::Converter

      register_for "csd"

      def initialize(backend, opts)
        super
        warn "The asciidoctor-csd gem has been deprecated and has been replaced by metanorma-csd"
      end

      def metadata_author(node, xml)
        xml.contributor do |c|
          c.role **{ type: "author" }
          c.organization do |a|
            a.name "CalConnect"
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
        end
      end

      def title(node, xml)
        ["en"].each do |lang|
          xml.title **{ language: lang, format: "plain" } do |t|
            t << asciidoc_sub(node.attr("title"))
          end
        end
      end

      def metadata_status(node, xml)
        xml.status(**{ format: "plain" }) { |s| s << node.attr("status") }
      end

      def metadata_id(node, xml)
        xml.docidentifier { |i| i << node.attr("docnumber") }
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

      def title_validate(root)
        nil
      end

      def makexml(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<csd-standard>"]
        @draft = node.attributes.has_key?("draft")
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</csd-standard>"
        result = textcleanup(result.flatten * "\n")
        ret1 = cleanup(Nokogiri::XML(result))
        validate(ret1)
        ret1.root.add_namespace(nil, CSD_NAMESPACE)
        ret1
      end

      def doctype(node)
        d = node.attr("doctype")
        unless %w{presentation code proposal standard report}.include? d
          warn "#{d} is not a legal document type: reverting to 'standard'"
          d = "standard"
        end
        d
      end

      def pdf_convert(filename)
        url = "#{Dir.pwd}/#{filename}.html"
        pdfjs = File.join(File.dirname(__FILE__), 'pdf.js')
        system "export NODE_PATH=$(npm root --quiet -g);
                node #{pdfjs} file://#{url} #{filename}.pdf"
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
          pdf_convert(filename.sub(/\.xml$/, ""))
        end
        @files_to_delete.each { |f| system "rm #{f}" }
        ret
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "csd.rng"))
      end

      def literal(node)
        noko do |xml|
          xml.figure **id_attr(node) do |f|
            figure_title(node, f)
            f.pre node.lines.join("\n")
          end
        end
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

      def inline_quoted(node)
        noko do |xml|
          case node.type
          when :emphasis then xml.em node.text
          when :strong then xml.strong node.text
          when :monospaced then xml.tt node.text
          when :double then xml << "\"#{node.text}\""
          when :single then xml << "'#{node.text}'"
          when :superscript then xml.sup node.text
          when :subscript then xml.sub node.text
          when :asciimath then stem_parse(node.text, xml)
          else
            case node.role
            when "strike" then xml.strike node.text
            when "smallcap" then xml.smallcap node.text
            when "keyword" then xml.keyword node.text
            else
              xml << node.text
            end
          end
        end.join
      end

    end
  end
end
