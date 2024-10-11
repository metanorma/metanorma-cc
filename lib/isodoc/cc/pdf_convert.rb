require_relative "base_convert"
require "metanorma-generic"
require "isodoc"

module IsoDoc
  module Cc
    class PdfConvert < IsoDoc::Generic::PdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      include BaseConvert
      include Init
    end
  end
end


