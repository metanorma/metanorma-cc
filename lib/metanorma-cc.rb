require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "metanorma/cc/converter"
require_relative "metanorma/cc/cleanup"
require_relative "metanorma/cc/validate"
require_relative "isodoc/cc/html_convert"
require_relative "isodoc/cc/word_convert"
require_relative "isodoc/cc/pdf_convert"
require_relative "metanorma/cc/version"
require "metanorma-core"

if defined? Metanorma::Registry
  require_relative "metanorma/cc"
  Metanorma::Registry.instance.register(Metanorma::Cc::Processor)
end
