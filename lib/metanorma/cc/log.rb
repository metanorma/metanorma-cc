module Metanorma
  module Cc
    class Converter
      CC_LOG_MESSAGES = {
        # rubocop:disable Naming/VariableNumber
        "CC_1": { category: "Style",
                  error: "Only one Symbols and Abbreviated Terms section in the standard",
                  severity: 2 },
        "CC_2": { category: "Style",
                  error: "Symbols and Abbreviated Terms can only contain a definition list",
                  severity: 2 },
        "CC_3": { category: "Style",
                  error: "(section sequencing) %s",
                  severity: 2 },
        "CC_4": { category: "Style",
                  error: "Document must contain at least one clause",
                  severity: 2 },
        "CC_5": { category: "Style",
                  error: "Document must contain clause after Terms and Definitions",
                  severity: 2 },
        "CC_6": { category: "Style",
                  error: "Scope must occur before Terms and Definitions",
                  severity: 2 },
        "CC_8": { category: "Style",
                  error: "Only annexes and references can follow clauses",
                  severity: 2 },
        "CC_9": { category: "Style",
                  error: "Document must include (references) Normative References",
                  severity: 2 },
        "CC_11": { category: "Style",
                   error: "Final section must be (references) Bibliography",
                   severity: 2 },
        "CC_12": { category: "Style",
                   error: "There are sections after the final Bibliography",
                   severity: 2 },

      }.freeze
      # rubocop:enable Naming/VariableNumber

      def log_messages
        super.merge(CC_LOG_MESSAGES)
      end
    end
  end
end
