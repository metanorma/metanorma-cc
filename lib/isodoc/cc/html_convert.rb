require_relative "base_convert"
require_relative "init"
require "isodoc"

module IsoDoc
  module CC
    # A {Converter} implementation that generates CC output, and a document
    # schema encapsulation of the document for validation
    class HtmlConvert < IsoDoc::HtmlConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Source Sans Pro",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Source Sans Pro",sans-serif'),
          monospacefont: '"Source Code Pro",monospace'
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: html_doc_path("htmlstyle.scss"),
          htmlcoverpage: html_doc_path("html_cc_titlepage.html"),
          htmlintropage: html_doc_path("html_cc_intro.html"),
          scripts: html_doc_path("scripts.html"),
        }
      end

      def googlefonts()
        <<~HEAD.freeze
    <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:400,400i,700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Source+Code+Pro:ital,wght@0,400;0,700;1,400;1,700&display=swap" rel="stylesheet">
        HEAD
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72", "xml:lang": "EN-US", class: "container" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      include BaseConvert
      include Init
    end
  end
end

