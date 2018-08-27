require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/csd/converter"
require_relative "isodoc/csd/html_convert"
require_relative "isodoc/csd/word_convert"
require_relative "asciidoctor/csd/version"

if defined? Metanorma
  require_relative "metanorma/csd"
  Metanorma::Registry.instance.register(Metanorma::Csd::Processor)
end
