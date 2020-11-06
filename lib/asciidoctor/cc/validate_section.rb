require "nokogiri"
require "metanorma-generic"

module Asciidoctor
  module CC
    class Converter < Asciidoctor::Generic::Converter
      def section_validate(doc)
        advisory = doc.root.at("//bibdata/ext[doctype = 'advisory']")
        symbols_validate(doc.root) unless advisory
        sections_sequence_validate(doc.root) unless advisory
        super
      end

      ONE_SYMBOLS_WARNING = "Only one Symbols and Abbreviated "\
        "Terms section in the standard".freeze

      NON_DL_SYMBOLS_WARNING = "Symbols and Abbreviated Terms can "\
        "only contain a definition list".freeze

      def symbols_validate(root)
        f = root.xpath("//definitions")
        f.empty? && return
        (f.size == 1) || @log.add("Style", f.first, ONE_SYMBOLS_WARNING)
        f.first.elements.each do |e|
          unless e.name == "dl"
            @log.add("Style", f.first, NON_DL_SYMBOLS_WARNING)
            return
          end
        end
      end

      def seqcheck(names, msg, accepted)
        n = names.shift
        return [] if n.nil?
        test = accepted.map { |a| n.at(a) }
        if test.all? { |a| a.nil? }
          @log.add("Style", nil, msg)
        end
        names
      end

      # spec of permissible section sequence
      # we skip normative references, it goes to end of list
      SEQ =
        [
          {
            msg: "Initial section must be (content) Foreword",
            val:  ["./self::foreword"]
          },
          {
            msg: "Prefatory material must be followed by (clause) Scope",
            val:  ["./self::introduction", "./self::clause[@type = 'scope']" ]
          },
          {
            msg: "Prefatory material must be followed by (clause) Scope",
            val: ["./self::clause[@type = 'scope']" ]
          },
          {
            msg: "Normative References must be followed by "\
            "Terms and Definitions",
            val: ["./self::terms | .//terms"]
          },
      ].freeze

      SECTIONS_XPATH =
        "//foreword | //introduction | //sections/terms | .//annex | "\
        "//sections/definitions | //sections/clause | //references[not(parent::clause)] | "\
        "//clause[descendant::references][not(parent::clause)]".freeze

      def sections_sequence_validate(root)
        names = root.xpath(SECTIONS_XPATH)
        names = seqcheck(names, SEQ[0][:msg], SEQ[0][:val]) 
        n = names[0]
        names = seqcheck(names, SEQ[1][:msg], SEQ[1][:val])
        if n&.at("./self::introduction")
          names = seqcheck(names, SEQ[2][:msg], SEQ[2][:val]) 
        end
        names = seqcheck(names, SEQ[3][:msg], SEQ[3][:val]) 
        n = names.shift
        if n&.at("./self::definitions")
          n = names.shift 
        end
        if n.nil? || n.name != "clause"
          @log.add("Style", nil, "Document must contain at least one clause")
        end
        n&.at("./self::clause") ||
          @log.add("Style", nil, "Document must contain clause after "\
               "Terms and Definitions")
        n&.at("./self::clause[@type = 'scope']") &&
          @log.add("Style", nil, "Scope must occur before Terms and Definitions")
        n = names.shift 
        while n&.name == "clause"
          n&.at("./self::clause[@type = 'scope']")
            @log.add("Style", nil, "Scope must occur before Terms and Definitions")
          n = names.shift 
        end
         unless %w(annex references).include? n&.name
          @log.add("Style", nil, "Only annexes and references can follow clauses")
        end
         while n&.name == "annex"
          n = names.shift
          if n.nil?
            @log.add("Style", nil, "Document must include (references) "\
                 "Normative References")
          end
        end
         n&.at("./self::references[@normative = 'true']") ||
          @log.add("Style", nil, "Document must include (references) "\
               "Normative References")
        n = names&.shift
        n&.at("./self::references[@normative = 'false']") ||
          @log.add("Style", nil, "Final section must be (references) Bibliography")
        names.empty? ||
          @log.add("Style", nil, "There are sections after the final Bibliography")
      end

      def style_warning(node, msg, text = nil)
        return if @novalid
        w = msg
        w += ": #{text}" if text
        @log.add("Style", node, w)
      end
    end
  end
end
