require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/cc/converter"
require_relative "isodoc/cc/html_convert"
require_relative "isodoc/cc/word_convert"
require_relative "isodoc/cc/pdf_convert"
require_relative "metanorma/cc/version"

if defined? Metanorma
  require_relative "metanorma/cc"
  Metanorma::Registry.instance.register(Metanorma::CC::Processor)
end
