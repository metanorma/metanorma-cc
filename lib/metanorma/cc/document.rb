# frozen_string_literal: true

# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/cc.rb).
module Metanorma
  module Cc
    autoload :Registers, "metanorma/cc/registers"
  end
end

require "metanorma-generic"

module Metanorma
  module Cc::Document
    autoload :Root, "metanorma/cc/document/root"
  end
end

require "metanorma-core"

# OCP adoption: ONE registration in the metanorma-core flavor table
# (metanorma-core#18). Lazy: the table exists only on the flavor-table
# line of metanorma-core; skip silently on resolutions without it.
if defined?(Metanorma::Core::Flavors)
  Metanorma::Cc::Registers.setup
  Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
                                      name: :cc,
                                      gem: "metanorma-cc",
                                      model_root: Metanorma::Cc::Document::Root,
                                      pubid_module: nil,
                                      renderers: { html: lambda do |_document, **_options|
                                        Metanorma::Html::StandardRenderer
                                      end },
                                    ))
end
