require "asciidoctor"
require "asciidoctor/csd/version"
require "asciidoctor/csd/csdconvert"
require "asciidoctor/iso/converter"

module Asciidoctor
  module Csd
    CSD_NAMESPACE = "https://www.calconnect.org/standards/csd"

    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class Converter < ISO::Converter

      register_for "csd"

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
            t << node.attr("title")
          end
        end
      end

      def metadata_status(node, xml)
        xml.status **{ format: "plain" } { |s| s << node.attr("status") }
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

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "csd.rng"))
      end

      def html_doc_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def literal(node)
        noko do |xml|
          xml.figure **id_attr(node) do |f|
            figure_title(node, f)
            f.pre node.lines.join("\n")
          end
        end
      end

      def sections_cleanup(xmldoc)
        super
        xmldoc.xpath("//*[@inline-header]").each do |x|
          x.delete("inline-header")
        end
      end

      def style(n, t)
        return
      end

      def html_converter(_node)
        CsdConvert.new(
          htmlstylesheet: generate_css(html_doc_path("htmlstyle.scss"), true),
          standardstylesheet: generate_css(html_doc_path("csd.scss"), true),
          htmlcoverpage: html_doc_path("html_csd_titlepage.html"),
          htmlintropage: html_doc_path("html_csd_intro.html"),
        )
      end

      def doc_converter(_node)
        CsdWordConvert.new(
          wordstylesheet: generate_css(html_doc_path("wordstyle.scss"), false),
          standardstylesheet: generate_css(html_doc_path("csd.scss"), false),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_csd_titlepage.html"),
          wordintropage: html_doc_path("word_csd_intro.html"),
        )
      end

      def default_fonts(node)
        b = node.attr("body-font") ||
          (node.attr("script") == "Hans" ? '"SimSun",serif' :
           '"Source Sans Pro",sans-serif')
        h = node.attr("header-font") ||
          (node.attr("script") == "Hans" ? '"SimHei",sans-serif' :
           '"Source Sans Pro",sans-serif')
        m = node.attr("monospace-font") || '"Courier New",monospace'
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
      end
    end
  end
end
