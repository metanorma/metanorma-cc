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
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//bibdata/title[@language='en']"))&.text
        set(:doctitle, main)
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(isoxml, _out)
        set(:tc, "XXXX")
        tc = isoxml.at(ns("//bibdata/editorialgroup/technical-committee"))
        set(:tc, tc.text) if tc
        authors = isoxml.xpath(ns("//bibdata/contributor[role/@type = 'author']/person/name"))
        set(:authors, extract_person_names(authors))
        editors = isoxml.xpath(ns("//bibdata/contributor[role/@type = 'editor']/person/name"))
        set(:editors, extract_person_names(editors))
      end

      def extract_person_names(authors)
        ret = []
        authors.each do |a|
          if a.at(ns("./completename"))
            ret << a.at(ns("./completename")).text
          else
            fn = []
            forenames = a.xpath(ns("./forename"))
            forenames.each { |f| fn << f.text }
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
        %w(published withdrawn).include? status.downcase
      end
    end
  end
end
