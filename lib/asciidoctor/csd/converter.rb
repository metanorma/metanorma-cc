require "asciidoctor"
require "asciidoctor/csd/version"
require "asciidoctor/iso"
#require "asciidoctor/iso/isoxml/base"
#require "asciidoctor/iso/isoxml/front"
#require "asciidoctor/iso/isoxml/lists"
#require "asciidoctor/iso/isoxml/inline_anchor"
#require "asciidoctor/iso/isoxml/blocks"
#require "asciidoctor/iso/isoxml/section"
#require "asciidoctor/iso/isoxml/table"
#require "asciidoctor/iso/isoxml/validate"
#require "asciidoctor/iso/isoxml/utils"
#require "asciidoctor/iso/isoxml/cleanup"

module Asciidoctor
  module Csd
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class Converter < ISO::Converter

      register_for "csd"

      alias_method :inline_image, :skip
    end
  end
end
