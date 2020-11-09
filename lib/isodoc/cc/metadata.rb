require "isodoc"
require "metanorma/cc"

module IsoDoc
  module CC
    class Metadata < IsoDoc::Generic::Metadata
      def configuration
        Metanorma::CC.configuration
      end

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
        tc = isoxml.at(ns("//bibdata/ext/editorialgroup/committee"))
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
    end
  end
end
