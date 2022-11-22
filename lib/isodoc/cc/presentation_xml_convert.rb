require_relative "init"
require "metanorma-generic"
require "isodoc"

module IsoDoc
  module CC
    class PresentationXMLConvert < IsoDoc::Generic::PresentationXMLConvert
      def annex1(elem)
        lbl = @xrefs.anchor(elem["id"], :label)
        if t = elem.at(ns("./title"))
          t.children = "<strong>#{to_xml(t.children)}</strong>"
        end
        prefix_name(elem, "<br/>", lbl, "title")
      end

      include Init
    end
  end
end
