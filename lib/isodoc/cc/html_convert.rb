require_relative "base_convert"
require "isodoc/generic/html_convert"
require_relative "init"
require "isodoc"

module IsoDoc
  module CC
    # A {Converter} implementation that generates CC output, and a document
    # schema encapsulation of the document for validation
    class HtmlConvert < IsoDoc::Generic::HtmlConvert

      include BaseConvert
      include Init
    end
  end
end

