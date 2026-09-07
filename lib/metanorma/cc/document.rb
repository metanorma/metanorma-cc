# frozen_string_literal: true

require "metanorma/standoc"
# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/cc.rb).
module Metanorma
  module Cc
  end
end


module Metanorma
  module Cc::Document
    autoload :Metadata, "metanorma/cc/document/metadata"
    autoload :Root, "metanorma/cc/document/root"
  end
end

# Backwards-compat alias so external consumers that reference
# Metanorma::CcDocument keep resolving during the transition.
module Metanorma
  existing = defined?(Metanorma::CcDocument) && Metanorma::CcDocument
  if !existing.equal?(Metanorma::Cc::Document)
    Metanorma.send(:remove_const, :CcDocument) if existing
    CcDocument = Metanorma::Cc::Document
  end
end

if defined?(Metanorma::Registers::Setup.setup_cc_register)
  Metanorma::Registers::Setup.setup_cc_register
end

module Metanorma
  deprecate_constant :CcDocument
end
