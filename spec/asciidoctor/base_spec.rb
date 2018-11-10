require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Csd do
  it "has a version number" do
    expect(Metanorma::Csd::VERSION).not_to be nil
  end

  it "generates output for the Rice document" do
    FileUtils.rm_rf %w(spec/examples/rfc6350.doc spec/examples/rfc6350.html spec/examples/rfc6350.pdf)
    FileUtils.cd "spec/examples"
    Asciidoctor.convert_file "rfc6350.adoc", {:attributes=>{"backend"=>"csd"}, :safe=>0, :header_footer=>true, :requires=>["metanorma-csd"], :failure_level=>4, :mkdirs=>true, :to_file=>nil}
    FileUtils.cd "../.."
    expect(File.exist?("spec/examples/rfc6350.doc")).to be true
    expect(File.exist?("spec/examples/rfc6350.html")).to be true
    expect(File.exist?("spec/examples/rfc6350.pdf")).to be true
  end

  it "processes a blank document" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</csd-standard>
    OUTPUT
  end

  it "converts a blank document" do
    FileUtils.rm_f "test.html"
    expect(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
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
  end

  it "overrides invalid document type" do
    FileUtils.rm_f "test.html"
    expect(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :doctype: dinosaur
    INPUT
    #{BLANK_HDR}
<sections/>
</csd-standard>
    OUTPUT
    expect(File.exist?("test.html")).to be true
  end

  it "processes default metadata for final-draft directive with copyright year" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
    INPUT
<?xml version="1.0" encoding="UTF-8"?>
<csd-standard xmlns="https://www.calconnect.org/standards/csd">
<bibdata type="directive">
  <title language="en" format="text/plain">Main Title</title>
  <docidentifier type="csd">CC/DIR/FDS 1000:2001</docidentifier>
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
  <status format="plain">final-draft</status>
  <copyright>
    <from>2001</from>
    <owner>
      <organization>
        <name>CalConnect</name>
      </organization>
    </owner>
  </copyright>
  <editorialgroup>
    <technical-committee type="provisional">TC</technical-committee>
  </editorialgroup>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
<sections/>
</csd-standard>
    OUTPUT
  end

  it "processes default metadata for published technical-corrigendum" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
       <csd-standard xmlns="https://www.calconnect.org/standards/csd">
       <bibdata type="technical-corrigendum">
         <title language="en" format="text/plain">Main Title</title>
        <docidentifier type="csd">CC/Cor 1000</docidentifier>
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
         <status format="plain">published</status>
         <copyright>
           <from>2018</from>
           <owner>
             <organization>
               <name>CalConnect</name>
             </organization>
           </owner>
         </copyright>
         <editorialgroup>
           <technical-committee type="provisional">TC 788</technical-committee>
           <technical-committee type="technical">TC 789</technical-committee>
         </editorialgroup>
       </bibdata><version>
         <edition>2</edition>
       </version>
       <sections/>
       </csd-standard>
        OUTPUT
    end

  it "ignores unrecognised status" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
      :status: pizza
      :iteration: 3
      :language: en
      :title: Main Title
    INPUT
       <?xml version="1.0" encoding="UTF-8"?>
       <csd-standard xmlns="https://www.calconnect.org/standards/csd">
       <bibdata type="technical-corrigendum">
         <title language="en" format="text/plain">Main Title</title>
        <docidentifier type="csd">CC/Cor 1000</docidentifier>
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
         <status format="plain">pizza</status>
         <copyright>
           <from>2018</from>
           <owner>
             <organization>
               <name>CalConnect</name>
             </organization>
           </owner>
         </copyright>
         <editorialgroup>
           <technical-committee type="provisional">TC 788</technical-committee>
           <technical-committee type="technical">TC 789</technical-committee>
         </editorialgroup>
       </bibdata><version>
         <edition>2</edition>
       </version>
       <sections/>
       </csd-standard>
        OUTPUT
    end

  it "processes figures" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}

      [[id]]
      .Figure 1
      ....
      This is a literal

      Amen
      ....
      INPUT
    #{BLANK_HDR}
       <sections>
                <figure id="id">
         <name>Figure 1</name>
         <pre>This is a literal

       Amen</pre>
       </figure>
       </sections>
       </csd-standard>
    OUTPUT
  end

  it "strips inline header" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
      INPUT
    #{BLANK_HDR}
             <preface><foreword obligation="informative">
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
    Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Overpass", sans-serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Overpass", sans-serif;]m)
  end

  it "uses default fonts (Word)" do
    FileUtils.rm_f "test.doc"
    Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^}]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Arial", sans-serif;]m)
    expect(html).to match(%r[h1 \{[^}]+font-family: "Arial", sans-serif;]m)
  end

  it "uses Chinese fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "SimHei", sans-serif;]m)
  end

  it "uses specified fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[ div,[^{]+\{[^}]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Comic Sans;]m)
  end

  it "processes inline_quoted formatting" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
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
       "double quote"
       'single quote'
       super<sup>script</sup>
       sub<sub>script</sub>
       <stem type="AsciiMath">a_90</stem>
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
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(/is not a legal document type/).to_stderr }
  #{VALIDATING_BLANK_HDR}
      = Document title
      Author
      :docfile: test.adoc
      :doctype: dinosaur

  INPUT
end

RSpec.describe "warns about illegal status" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(/is not a legal status/).to_stderr }
  #{VALIDATING_BLANK_HDR}
      = Document title
      Author
      :docfile: test.adoc
      :status: dinosaur

  INPUT
end

