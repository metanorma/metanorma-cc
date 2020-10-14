require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::CC do
  it "has a version number" do
    expect(Metanorma::CC::VERSION).not_to be nil
  end

  #it "generates output for the Rice document" do
  #  FileUtils.rm_rf %w(spec/examples/rfc6350.doc spec/examples/rfc6350.html spec/examples/rfc6350.pdf)
  #  FileUtils.cd "spec/examples"
  #  Asciidoctor.convert_file "rfc6350.adoc", {:attributes=>{"backend"=>"cc"}, :safe=>0, :header_footer=>true, :requires=>["metanorma-cc"], :failure_level=>4, :mkdirs=>true, :to_file=>nil}
  #  FileUtils.cd "../.."
  #  expect(File.exist?("spec/examples/rfc6350.doc")).to be true
  #  expect(File.exist?("spec/examples/rfc6350.html")).to be true
  #  expect(File.exist?("spec/examples/rfc6350.pdf")).to be true
  #end

  it "processes a blank document" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    #{BLANK_HDR}
<sections/>
</csd-standard>
    OUTPUT
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.pdf")).to be true
    expect(File.exist?("test.doc")).to be true
  end

  it "overrides invalid document type" do
    FileUtils.rm_f "test.html"
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :doctype: dinosaur
      :no-pdf:
    INPUT
    #{BLANK_HDR}
<sections/>
</csd-standard>
    OUTPUT
    expect(File.exist?("test.html")).to be true
  end

  it "processes default metadata for final-draft directive with copyright year" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<?xml version="1.0" encoding="UTF-8"?>
<csd-standard xmlns="https://www.metanorma.org/ns/csd" type="semantic" version="#{Metanorma::CC::VERSION}">
<bibdata type="standard">
  <title language="en" format="text/plain">Main Title</title>
  <docidentifier type="CalConnect">CC/DIR/FDS 1000:2001</docidentifier>
  <docnumber>1000</docnumber>
  <edition>2</edition>
<version>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>  <contributor>
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
  <doctype>directive</doctype>
  <editorialgroup>
    <technical-committee type="provisional">TC</technical-committee>
  </editorialgroup>
  </ext>
</bibdata>
    #{BOILERPLATE.sub(/<legal-statement/, "#{BOILERPLATE_LICENSE}\n<legal-statement").sub(/#{Date.today.year} The Calendaring and Scheduling Consortium/, "2001 The Calendaring and Scheduling Consortium")}
<sections/>
</csd-standard>
    OUTPUT
  end

  it "processes default metadata for published technical-corrigendum" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
       <?xml version="1.0" encoding="UTF-8"?>
       <csd-standard xmlns="https://www.metanorma.org/ns/csd" type="semantic" version="#{Metanorma::CC::VERSION}">
       <bibdata type="standard">
         <title language="en" format="text/plain">Main Title</title>
         <docidentifier type="CalConnect">CC/Cor 1000</docidentifier>
         <docnumber>1000</docnumber>
         <edition>2</edition>
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
         <doctype>technical-corrigendum</doctype>
         <editorialgroup>
           <technical-committee type="provisional">TC 788</technical-committee>
           <technical-committee type="technical">TC 789</technical-committee>
         </editorialgroup>
         </ext>
       </bibdata>
#{BOILERPLATE}
       <sections/>
       </csd-standard>
        OUTPUT
    end

  it "ignores unrecognised status" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
       <?xml version="1.0" encoding="UTF-8"?>
       <csd-standard xmlns="https://www.metanorma.org/ns/csd" type="semantic" version="#{Metanorma::CC::VERSION}">
       <bibdata type="standard">
         <title language="en" format="text/plain">Main Title</title>
         <docidentifier type="CalConnect">CC/Cor 1000</docidentifier>
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
         <doctype>technical-corrigendum</doctype>
         </ext>
       </bibdata>
    #{BOILERPLATE.sub(/<legal-statement/, "#{BOILERPLATE_LICENSE}\n<legal-statement")}
       <sections/>
       </csd-standard>
        OUTPUT
    end

  it "strips inline header" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
      INPUT
    #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
         <title>Foreword</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" obligation="normative">
         <title>Section 1</title>
       </clause></sections>
       </csd-standard>
    OUTPUT
  end

  it "uses default fonts" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
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

  it "uses Chinese fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Source Code Pro", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "SimHei", sans-serif;]m)
  end

  it "uses specified fonts" do
    FileUtils.rm_f "test.html"
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

  it "processes inline_quoted formatting" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      _emphasis_
      *strong*
      `monospace`
      "double quote"
      'single quote'
      super^script^
      sub~script~
      stem:[a_90]
      stem:[<mml:math><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>]
      [keyword]#keyword#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT
    #{BLANK_HDR}
       <sections>
        <p id="_"><em>emphasis</em>
       <strong>strong</strong>
       <tt>monospace</tt>
       “double quote”
       ‘single quote’
       super<sup>script</sup>
       sub<sub>script</sub>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow>
  <mi>a</mi>
</mrow>
<mrow>
  <mn>90</mn>
</mrow>
</msub></math></stem>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
       <keyword>keyword</keyword>
       <strike>strike</strike>
       <smallcap>smallcap</smallcap></p>
       </sections>
       </csd-standard>
    OUTPUT
  end


end

RSpec.describe "warns when missing a title" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) }.to output(/is not a legal document type/).to_stderr }
  #{VALIDATING_BLANK_HDR}
      = Document title
      Author
      :docfile: test.adoc
      :doctype: dinosaur

  INPUT
end

RSpec.describe "warns about illegal status" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) }.to output(/is not a legal status/).to_stderr }
  #{VALIDATING_BLANK_HDR}
      = Document title
      Author
      :docfile: test.adoc
      :status: dinosaur

  INPUT
end

