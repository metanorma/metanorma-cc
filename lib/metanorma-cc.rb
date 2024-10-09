require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "metanorma/cc/converter"
require_relative "isodoc/cc/html_convert"
require_relative "isodoc/cc/word_convert"
require_relative "isodoc/cc/pdf_convert"
require_relative "metanorma/cc/version"
require "metanorma"

if defined? Metanorma::Registry
  require_relative "metanorma/cc"
  Metanorma::Registry.instance.register(Metanorma::Cc::Processor)
end
