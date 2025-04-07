require_relative "init"
require "metanorma-generic"
require "isodoc"

module IsoDoc
  module Cc
    class PresentationXMLConvert < IsoDoc::Generic::PresentationXMLConvert
      def annex_delim(_elem)
        "<br/>"
      end

      def ul_label_list(_elem)
        %w(&#x2014;)
      end

      include Init
    end
  end
end
