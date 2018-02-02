require "isodoc"

module Asciidoctor
  module Csd
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class CsdConvert < IsoDoc::Convert
      def initialize(options)
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
        tc = isoxml.at(ns("//technical-committee"))
        set_metadata(:tc, tc.text) if tc
      end


      def id(isoxml, _out)
        docnumber = isoxml.at(ns("//csd-standard/id"))
        docstatus = isoxml.at(ns("//csd-standard/status"))
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

      def populate_template(docxml)
        meta = get_metadata
        docxml.
          gsub(/DOCYEAR/, meta[:docyear]).
          gsub(/DOCNUMBER/, meta[:docnumber]).
          gsub(/TECHCOMMITTEE/, meta[:tc]).
          gsub(/DOCTITLE/, meta[:doctitle]).
          gsub(/DOCSTAGE/, meta[:status]).
          gsub(/\[TERMREF\]\s*/, "[SOURCE: ").
          gsub(/\s*\[\/TERMREF\]\s*/, "]").
          gsub(/\s*\[ISOSECTION\]/, ", ").
          gsub(/\s*\[MODIFICATION\]/, ", modified &mdash; ")
      end

      def generate_header(filename, dir)
        header = File.read(@header, encoding: "UTF-8").
          gsub(/FILENAME/, filename).
          gsub(/DOCYEAR/, get_metadata()[:docyear]).
          gsub(/DOCNUMBER/, get_metadata()[:docnumber])
        File.open("header.html", "w") do |f|
          f.write(header)
        end
      end


    end
  end
end

