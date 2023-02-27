require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::CC do
  it "has a version number" do
    expect(Metanorma::CC::VERSION).not_to be nil
  end

  it "processes a blank document" do
    options = [backend: :cc, header_footer: true]
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *options)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
    INPUT
        #{BLANK_HDR}
        <sections/>
      </csd-standard>
    OUTPUT
  end

  it "converts a blank document" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.pdf"
    FileUtils.rm_f "test.doc"
    options = [backend: :cc, header_footer: true]
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR}
        <sections/>
      </csd-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *options))))
      .to be_equivalent_to xmlpp(output)
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.pdf")).to be true
    expect(File.exist?("test.doc")).to be true
  end

  it "overrides invalid document type" do
    options = [backend: :cc, header_footer: true]
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :doctype: dinosaur
      :no-pdf:
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR}
        <sections/>
      </csd-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *options))))
      .to be_equivalent_to xmlpp(output)
    expect(File.exist?("test.html")).to be true
  end

  it "processes default metadata for final-draft directive with copyright year" do
    options = [backend: :cc, header_footer: true]
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: directive
      :edition: 2
      :revdate: 2000-01-01
      :draft: 3.4
      :technical-committee: TC
      :technical-committee-type: provisional
      :copyright-year: 2001
      :status: final-draft
      :iteration: 3
      :language: en
      :title: Main Title
      :fullname: Fred Flintstone
      :role: author
      :surname_2: Rubble
      :givenname_2: Barney
      :role_2: editor
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <csd-standard xmlns="https://www.metanorma.org/ns/csd" type="semantic" version="#{Metanorma::CC::VERSION}">
      <bibdata type="standard">
        <title language="en" format="text/plain">Main Title</title>
        <docidentifier type="CalConnect">CC/DIR/FDS 1000:2001</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>CalConnect</name>
          </organization>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
             <name>
               <completename>Fred Flintstone</completename>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name>
              <forename>Barney</forename>
              <surname>Rubble</surname>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>CalConnect</name>
          </organization>
        </contributor>
        <edition>2</edition>
        <version>
          <revision-date>2000-01-01</revision-date>
          <draft>3.4</draft>
        </version>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>final-draft</stage>
          <iteration>3</iteration>
        </status>
        <copyright>
          <from>2001</from>
          <owner>
            <organization>
              <name>CalConnect</name>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype abbreviation="DIR">directive</doctype>
          <editorialgroup>
            <committee type="provisional">TC</committee>
          </editorialgroup>
        </ext>
      </bibdata>
               <metanorma-extension>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
         </metanorma-extension>
      #{BOILERPLATE.sub(/<legal-statement/, "#{BOILERPLATE_LICENSE}\n<legal-statement") \
        .sub(/#{Date.today.year} The Calendaring and Scheduling Consortium/, \
             '2001 The Calendaring and Scheduling Consortium')}
      <sections/>
      </csd-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *options))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes default metadata for published technical-corrigendum" do
    options = [backend: :cc, header_footer: true]
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: technical-corrigendum
      :edition: 2
      :technical-committee: TC 788
      :technical-committee-type: provisional
      :technical-committee_2: TC 789
      :technical-committee-type_2: technical
      :secretariat: SECRETARIAT
      :status: published
      :iteration: 3
      :language: en
      :title: Main Title
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <csd-standard xmlns="https://www.metanorma.org/ns/csd" type="semantic" version="#{Metanorma::CC::VERSION}">
        <bibdata type="standard">
          <title language="en" format="text/plain">Main Title</title>
          <docidentifier type="CalConnect">CC/Cor 1000:#{Time.now.year}</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>CalConnect</name>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>CalConnect</name>
            </organization>
          </contributor>
          <edition>2</edition>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage>published</stage>
            <iteration>3</iteration>
          </status>
          <copyright>
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>CalConnect</name>
              </organization>
            </owner>
          </copyright>
          <ext>
          <doctype abbreviation="Cor">technical-corrigendum</doctype>
          <editorialgroup>
            <committee type="provisional">TC 788</committee>
            <committee type="technical">TC 789</committee>
          </editorialgroup>
          </ext>
        </bibdata>
                 <metanorma-extension>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
         </metanorma-extension>
         #{BOILERPLATE}
        <sections/>
      </csd-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *options))))
      .to be_equivalent_to xmlpp(output)
  end

  it "ignores unrecognised status" do
    options = [backend: :cc, header_footer: true]
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: technical-corrigendum
      :secretariat: SECRETARIAT
      :status: pizza
      :iteration: 3
      :language: en
      :title: Main Title
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <csd-standard xmlns="https://www.metanorma.org/ns/csd" type="semantic" version="#{Metanorma::CC::VERSION}">
        <bibdata type="standard">
          <title language="en" format="text/plain">Main Title</title>
          <docidentifier type="CalConnect">CC/Cor 1000:#{Time.now.year}</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>CalConnect</name>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>CalConnect</name>
            </organization>
          </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage>pizza</stage>
            <iteration>3</iteration>
          </status>
          <copyright>
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>CalConnect</name>
              </organization>
            </owner>
          </copyright>
          <ext>
          <doctype abbreviation="Cor">technical-corrigendum</doctype>
          </ext>
        </bibdata>
                 <metanorma-extension>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
         </metanorma-extension>
          #{BOILERPLATE.sub(/<legal-statement/, "#{BOILERPLATE_LICENSE}\n<legal-statement")}
        <sections/>
      </csd-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *options))))
      .to be_equivalent_to xmlpp(output)
  end

  it "strips inline header" do
    options = [backend: :cc, header_footer: true]
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
      <preface>
        <foreword id="_" obligation="informative">
          <title>Foreword</title>
          <p id="_">This is a preamble</p>
        </foreword>
      </preface>
      <sections>
        <clause id="_" obligation="normative">
          <title>Section 1</title>
        </clause>
      </sections>
      </csd-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *options))))
      .to be_equivalent_to xmlpp(output)
  end

  it "uses default fonts" do
    Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Source Code Pro", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Source Sans Pro", sans-serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Source Sans Pro", sans-serif;]m)
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Source Code Pro", "Courier New", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Source Sans Pro", "Arial", sans-serif;]m)
    expect(html).to match(%r[h1 \{[^}]+font-family: "Source Sans Pro", "Arial", sans-serif;]m)
  end

  it "uses specified fonts" do
    Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[ div,[^{]+\{[^}]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Comic Sans;]m)
  end
end
