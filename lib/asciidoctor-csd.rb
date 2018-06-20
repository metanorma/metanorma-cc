require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/csd/converter"
require_relative "isodoc/csd/csdconvert"
require_relative "asciidoctor/csd/version"

if defined? Metanorma
  require_relative "metanorma/csd"
  Metanorma::Registry.instance.register(Metanorma::Csd::Processor)
end
