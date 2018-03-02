require "isodoc"

module Asciidoctor
  module Csd
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class CsdConvert < IsoDoc::Convert
      def initialize(options)
        super
        set_metadata(:status, "XXX")
      end

      def init_metadata
        super
      end

      def title(isoxml, _out)
        main = isoxml.at(ns("//title[@language='en']")).text
        set_metadata(:doctitle, main)
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(isoxml, _out)
        set_metadata(:tc, "XXXX")
        tc = isoxml.at(ns("//isoworkgroup/technical-committee"))
        set_metadata(:tc, tc.text) if tc
      end


      def id(isoxml, _out)
        docnumber = isoxml.at(ns("//bibdata/docidentifier"))
        docstatus = isoxml.at(ns("//bibdata/status"))
        dn = docnumber.text
        if docstatus
          set_metadata(:status, status_print(docstatus.text))
          abbr = status_abbr(docstatus.text)
          dn = "#{dn}(#{abbr})" unless abbr.empty?
        end
        set_metadata(:docnumber, dn)
      end

      def status_print(status)
        status.split(/-/).map{ |w| w.capitalize }.join(" ")
      end

      def status_abbr(status)
        case status
        when "working-draft" then "wd"
        when "committee-draft" then "cd"
        when "draft-standard" then "d"
        else
          ""
        end
      end

      def annex_names(clause, num)
        obligation = "(Informative)"
        obligation = "(Normative)" if clause["subtype"] == "normative"
        label = "<b>Appendix #{num}</b><br/>#{obligation}"
        @anchors[clause["id"]] = { label: label,
                                   xref: "Appendix #{num}", level: 1 }
        clause.xpath(ns("./subsection")).each_with_index do |c, i|
          annex_names1(c, "#{num}.#{i + 1}", 2)
        end
        hierarchical_asset_names(clause, num)
      end

      def error_parse(node, out)
        # catch elements not defined in ISO
        case node.name
        when "pre" then pre_parse(node, out)
        else
          super
        end
      end

      def pre_parse(node, out)
        out.pre do |p|
          p << node.text
        end
      end

      TERM_DEF_BOILERPLATE = "".freeze

      def term_defs_boilerplate(div, source, term)
        if source.empty? && term.nil?
          div << "<p>No terms and definitions are listed in this document.</p>"
        else
          out = "<p>For the purposes of this document, " +
            term_defs_boilerplate_cont(source, term)
          div << out
        end
        div << TERM_DEF_BOILERPLATE
      end

    end
  end
end

