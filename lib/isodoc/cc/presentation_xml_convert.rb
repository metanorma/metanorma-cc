require_relative "init"
require "isodoc"

module IsoDoc
  module CC
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      include Init
    end
  end
end

