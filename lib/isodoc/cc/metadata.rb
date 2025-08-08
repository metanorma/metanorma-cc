require "isodoc"
require "metanorma/cc"

module IsoDoc
  module Cc
    class Metadata < IsoDoc::Generic::Metadata
      def configuration
        Metanorma::Cc.configuration
      end

      def initialize(lang, script, locale, labels)
        super
        set(:tc, "XXXX")
      end

      def title(isoxml, _out)
        main = isoxml.at(ns("//bibdata/title[@language='en']"))&.children&.to_xml
        set(:doctitle, main)
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(isoxml, _out)
        #tc = isoxml.at(ns("//bibdata/ext/editorialgroup/committee"))
        tc = isoxml.at(ns("//bibdata/contributor[role/@type = 'author'][role/description = 'committee']/organization/subdivision[@type = 'Technical committee']/name"))
        set(:tc, tc.text) if tc
        super
      end

      def personal_authors(isoxml)
        set(:roles_authors_affiliations, roles_authors_affiliations(isoxml))
        super
      end

      def roles_authors_affiliations(isoxml)
        isoxml.xpath(ns("//bibdata/contributor/role/@type"))
          .inject([]) { |m, t| m << t.value }
          .uniq.sort.each_with_object({}) do |r, m|
          names = isoxml.xpath(ns("//bibdata/contributor[role/@type = '#{r}']"\
                                  "/person"))
          names.empty? or m[r] = extract_person_names_affiliations(names)
        end
      end
    end
  end
end
