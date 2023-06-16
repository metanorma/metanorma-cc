require "metanorma/processor"

module Metanorma
  module CC
    class Processor < Metanorma::Generic::Processor

      def initialize
        @short = [:csd, :cc]
        @input_format = :asciidoc
        @asciidoctor_backend = :cc
      end

      def output_formats
        super.merge(
          html: "html",
          pdf: "pdf",
          doc: "doc"
        )
      end

      def fonts_manifest
        {
          "Source Sans Pro" => nil,
          "Source Serif Pro" => nil,
          "Source Code Pro" => nil,
          "Source Han Sans" => nil,
          "STIX Two Math" => nil,
          "Noto Sans" => nil,
          "Noto Sans HK" => nil,
          "Noto Sans JP" => nil,
          "Noto Sans KR" => nil,
          "Noto Sans SC" => nil,
          "Noto Sans TC" => nil,
          "Noto Sans Mono" => nil,
          "Noto Sans Mono CJK HK" => nil,
          "Noto Sans Mono CJK JP" => nil,
          "Noto Sans Mono CJK KR" => nil,
          "Noto Sans Mono CJK SC" => nil,
          "Noto Sans Mono CJK TC" => nil,
        }
      end

      def version
        "Metanorma::CC #{Metanorma::CC::VERSION}"
      end

      def output(isodoc_node, inname, outname, format, options={})
        case format
        when :html
          IsoDoc::CC::HtmlConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::CC::WordConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::CC::PdfConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::CC::PresentationXMLConvert.new(options).convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
