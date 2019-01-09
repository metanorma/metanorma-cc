require "isodoc"
require "metanorma/csd"

module IsoDoc
  module Csd
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class Metadata < IsoDoc::Metadata

      def initialize(lang, script, labels)
        super
        set(:status, "XXX")
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
        tc = isoxml.at(ns("//bibdata/editorialgroup/technical-committee"))
        set(:tc, tc.text) if tc
        set(:contributors, personal_authors(isoxml))
      end

      def personal_authors(isoxml)
        persons = {}
        roles = isoxml.xpath(ns("//bibdata/contributor/role/@type")).
          inject([]) { |m, t| m << t.value }
        roles.uniq.sort.each do |r|
          names = isoxml.xpath(ns("//bibdata/contributor[role/@type = '#{r}']"\
                                    "/person/name"))
          persons[r] = extract_person_names(names) unless names.empty?
        end
        persons
      end

      def extract_person_names(authors)
        ret = []
        authors.each do |a|
          if a.at(ns("./completename"))
            ret << a.at(ns("./completename")).text
          else
            fn = a.xpath(ns("./forename")).inject([]) { |m, f| m << f.text }
            surname = a&.at(ns("./surname"))&.text
            ret << fn.join(" ") + " " + surname
          end
        end
        ret
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

      def status_print(status)
        status.split(/-/).map{ |w| w.capitalize }.join(" ")
      end

      def status_abbr(status)
        ::Metanorma::Csd::DOCSTATUS[status] || ""
      end

      def unpublished(status)
        !%w(published withdrawn).include? status.downcase
      end
    end
  end
end
