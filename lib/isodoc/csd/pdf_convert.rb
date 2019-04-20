require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Csd
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::PdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Overpass",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Overpass",sans-serif'),
          monospacefont: '"Space Mono",monospace'
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: html_doc_path("htmlstyle.scss"),
          htmlcoverpage: html_doc_path("html_csd_titlepage.html"),
          htmlintropage: html_doc_path("html_csd_intro.html"),
          scripts_pdf: html_doc_path("scripts.pdf.html"),
        }
      end

      def googlefonts()
        <<~HEAD.freeze
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i|Space+Mono:400,700" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Overpass:300,300i,600,900" rel="stylesheet">
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

      def html_toc(docxml)
        docxml
      end

      include BaseConvert
    end
  end
end

