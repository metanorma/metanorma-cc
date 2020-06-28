require "isodoc"
require "metanorma/cc"

module IsoDoc
  module CC
    # A {Converter} implementation that generates CC output, and a document
    # schema encapsulation of the document for validation
    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        set(:tc, "XXXX")
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//bibdata/title[@language='en']"))&.text
        set(:doctitle, main)
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(isoxml, _out)
        tc = isoxml.at(ns("//bibdata/ext/editorialgroup/technical-committee"))
        set(:tc, tc.text) if tc
        super
      end

      def personal_authors(isoxml)
        persons = {}
        roles = isoxml.xpath(ns("//bibdata/contributor/role/@type")).
          inject([]) { |m, t| m << t.value }
        roles.uniq.sort.each do |r|
          names = isoxml.xpath(ns("//bibdata/contributor[role/@type = '#{r}']"\
                                    "/person"))
          persons[r] = extract_person_names_affiliations(names) unless names.empty?
        end
        set(:roles_authors_affiliations, persons)
        super
      end

      def docid(isoxml, _out)
        docnumber = isoxml.at(ns("//bibdata/docidentifier"))
        prefix = "CC"
        if docnumber.nil?
          set(:docnumber, prefix)
        else
          set(:docnumber, docnumber.text)
        end
      end

      def stage_abbr(status)
        ::Metanorma::CC::DOCSTATUS[status] || ""
      end

      def unpublished(status)
        !%w(published withdrawn).include? status.downcase
      end
    end
  end
end
