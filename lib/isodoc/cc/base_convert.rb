require "isodoc"

module IsoDoc
  module CC
    module BaseConvert
      def annex_name(annex, name, div)
        div.h1 **{ class: "Annex" } do |t|
          t << "#{@xrefs.anchor(annex['id'], :label)} "
          t.br
          t.b do |b|
            name&.children&.each { |c2| parse(c2, b) }
          end
        end
      end

      def i18n_init(lang, script)
        super
        @annex_lbl = "Appendix"
        @labels["annex"] = "Appendix"
      end

      def cleanup(docxml)
        super
        term_cleanup(docxml)
      end

      def term_cleanup(docxml)
        docxml.xpath("//p[@class = 'Terms']").each do |d|
          h2 = d.at("./preceding-sibling::*[@class = 'TermNum'][1]")
          h2.add_child("&nbsp;")
          h2.add_child(d.remove)
        end
        docxml
      end
    end
  end
end
