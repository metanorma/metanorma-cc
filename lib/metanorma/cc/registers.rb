# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Cc
    # CC's lutaml-model register: creates the :cc_document context.
    # The cc model chain is the standoc one (RootXmlMapping, standoc
    # section classes), so the fallback resolves through the ISO
    # register, matching the gb/ogc/jis flavor registers.
    module Registers
      module_function

      def setup
        reg = Lutaml::Model::Register.new(:cc_document,
                                          fallback: [:iso_document])
        Lutaml::Model::GlobalRegister.register(reg)
      end
    end
  end
end
