require "isodoc"

module Asciidoctor
  module Csd
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class CsdConvert < IsoDoc::Convert
      def self.title(isoxml, _out)
        main = isoxml.at(ns("//title[@language='en']")).text
        set_metadata(:doctitle, main)
      end

      def self.subtitle(_isoxml, _out)
        nil
      end

      def self.author(isoxml, _out)
        set_metadata(:tc, "XXXX")
        tc = isoxml.at(ns("//technical-committee"))
        set_metadata(:tc, tc.text) if tc
      end


      def self.id(isoxml, _out)
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

      def self.status_print(status)
        status.split(/-/).map{ |w| w.capitalize }.join(" ")
      end

      def self.status_abbr(status)
        case status
        when "working-draft" then "wd"
        when "committee-draft" then "cd"
        when "draft-standard" then "d"
        else
          ""
        end
      end

      def self.populate_template(docxml)
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

          def self.wordPreface(docxml)
      fn = File.join(File.dirname(__FILE__), "csd_intro.html")
      intropage = File.read(fn, encoding: "UTF-8")
      div2 = docxml.at('//div[@class="WordSection2"]')
      div2.children.first.add_previous_sibling intropage
      #File.open("2.html", "w") {|f| f.write(docxml.to_xml)}
      docxml
    end

    def self.toWord(result, filename, dir)
      result = wordPreface(Nokogiri::HTML(result)).to_xml
      Html2Doc.process(result, filename, File.join(File.dirname(__FILE__), "wordstyle.css"), "header.html", dir)
    end

        def self.htmlstyle(docxml)
      fn = File.join(File.dirname(__FILE__), "htmlstyle.css")
      title = docxml.at("//*[local-name() = 'head']/*[local-name() = 'title']")
      head = docxml.at("//*[local-name() = 'head']")
      css = htmlstylesheet
      if title.nil?
        head.children.first.add_previous_sibling css
      else
        title.add_next_sibling css
      end
      docxml
    end

      def self.titlepage(_docxml, div)
        fn = File.join(File.dirname(__FILE__), "csd_titlepage.html")
        titlepage = File.read(fn, encoding: "UTF-8")
        div.parent.add_child titlepage
      end

      def self.define_head(html, filename, dir)
        html.head do |head|
          head.title { |t| t << filename }
          head.style do |style|
            fn = File.join(File.dirname(__FILE__), "csd.css")
            stylesheet = File.read(fn).gsub("FILENAME", filename)
            style.comment "\n#{stylesheet}\n"
          end
        end
      end

      def self.generate_header(filename, dir)
        hdr_file = File.join(File.dirname(__FILE__), "header.html")
        header = File.read(hdr_file, encoding: "UTF-8").
          gsub(/FILENAME/, filename).
          gsub(/DOCYEAR/, get_metadata()[:docyear]).
          gsub(/DOCNUMBER/, get_metadata()[:docnumber])
        File.open("header.html", "w") do |f|
          f.write(header)
        end
      end

    def self.htmlstylesheet
      fn = File.join(File.dirname(__FILE__), "htmlstyle.css")
      stylesheet = File.read(fn, encoding: "UTF-8")
      xml = Nokogiri::XML("<style/>")
      xml.children.first << Nokogiri::XML::Comment.new(xml, "\n#{stylesheet}\n")
      xml.root.to_s
    end


    end
  end
end

