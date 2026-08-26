# frozen_string_literal: true

require "metanorma/standoc"
require "metanorma/iso/document/models"

module Metanorma
  module Cc
  end
end

module Metanorma
  module Cc::Document
    autoload :Metadata, "#{__dir__}/document/metadata"
    autoload :Root, "#{__dir__}/document/root"
  end
end

module Metanorma
  existing = defined?(Metanorma::CcDocument) && Metanorma::CcDocument
  if !existing.equal?(Metanorma::Cc::Document)
    Metanorma.send(:remove_const, :CcDocument) if existing
    CcDocument = Metanorma::Cc::Document
  end
end

# OCP adoption: ONE registration in the metanorma-core flavor table
require "metanorma-core"
require "metanorma/iso/html"

Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
  name: :cc,
  gem: "metanorma-cc",
  model_root: Metanorma::Cc::Document::Root,
  renderers: { html: Metanorma::Iso::Html::Renderer },
))
