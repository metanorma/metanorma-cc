require_relative "base_convert"
require "isodoc/generic/word_convert"
require_relative "init"
require "isodoc"

module IsoDoc
  module CC
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class WordConvert < IsoDoc::Generic::WordConvert

      include BaseConvert
      include Init
    end
  end
end

