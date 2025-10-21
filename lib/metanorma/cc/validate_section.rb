require "nokogiri"
require "metanorma-generic"

module Metanorma
  module Cc
    class Converter < Metanorma::Generic::Converter
      def section_validate(doc)
        advisory = doc.root.at("//bibdata/ext[doctype = 'advisory']")
        symbols_validate(doc.root) unless advisory
        sections_sequence_validate(doc.root) unless advisory
        super
      end

      def symbols_validate(root)
        f = root.xpath("//definitions")
        f.empty? && return
        f.size == 1 or @log.add("CC_1", f.first)
        f.first.elements.each do |e|
          unless e.name == "dl"
            @log.add("CC_2", f.first)
            return
          end
        end
      end

      def seqcheck(names, msg, accepted)
        n = names.shift
        return [] if n.nil?

        test = accepted.map { |a| n.at(a) }
        if test.all?(&:nil?)
          @log.add("CC_3", nil, params: [msg])
        end
        names
      end

      # spec of permissible section sequence
      # we skip normative references, it goes to end of list
      SEQ =
        [
          {
            msg: "Initial section must be (content) Foreword",
            val: ["./self::foreword"],
          },
          {
            msg: "Prefatory material must be followed by (clause) Scope",
            val: ["./self::introduction", "./self::clause[@type = 'scope']"],
          },
          {
            msg: "Prefatory material must be followed by (clause) Scope",
            val: ["./self::clause[@type = 'scope']"],
          },
          {
            msg: "Normative References must be followed by "\
                 "Terms and Definitions",
            val: ["./self::terms | .//terms"],
          },
        ].freeze

      SECTIONS_XPATH =
        "//foreword | //introduction | //sections/terms | .//annex | "\
        "//sections/definitions | //sections/clause | "\
        "//references[not(parent::clause)] | "\
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
          @log.add("CC_4", nil)
        end
        n&.at("./self::clause") ||
          @log.add("CC_5", nil)
        n&.at("./self::clause[@type = 'scope']") &&
          @log.add("CC_6", nil)
        n = names.shift
        while n&.name == "clause"
          n&.at("./self::clause[@type = 'scope']")
          @log.add("CC_6", nil)
          n = names.shift
        end
        unless %w(annex references).include? n&.name
          @log.add("CC_8", nil)
        end
        while n&.name == "annex"
          n = names.shift
          if n.nil?
            @log.add("CC_9", nil)

          end
        end
        n&.at("./self::references[@normative = 'true']") ||
          @log.add("CC_9", nil)
        n = names&.shift
        n&.at("./self::references[@normative = 'false']") ||
          @log.add("CC_11", nil)
        names.empty? ||
          @log.add("CC_12", nil)
      end

      def style_warning(node, msg, text = nil)
        return if @novalid

        w = msg
        w += ": #{text}" if text
        @log.add("STANDOC_48", node, params: [w])
      end
    end
  end
end
