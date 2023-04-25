require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::CC do
  it "processes default metadata" do
    csdc = IsoDoc::CC::HtmlConvert.new({})
    docxml, = csdc.convert_init(<<~"INPUT", "test", true)
      <csd-standard xmlns="https://www.calconnect.org/standards/csd">
      <bibdata type="standard">
        <title language="en" format="plain">Main Title</title>
        <docidentifier>CC/WD 1000:2001</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>CalConnect</name>
          </organization>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name>
              <completename>Fred Flintstone</completename>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <forename>Barney</forename>
              <surname>Rubble</surname>
            </name>
            <affiliation>
              <organization><name>Bedrock Inc.</name></organization>
            </affiliation>
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
          <stage>working-draft</stage>
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
          <doctype>standard</doctype>
          <editorialgroup>
            <committee type="A">TC</committee>
          </editorialgroup>
        </ext>
      </bibdata>
      <sections/>
      </csd-standard>
    INPUT
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s
      .gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
        {:accesseddate=>"XXX",
        :agency=>"CalConnect",
        :authors=>["Fred Flintstone", "Barney Rubble"],
        :authors_affiliations=>{""=>["Fred Flintstone"], "Bedrock Inc."=>["Barney Rubble"]},
        :circulateddate=>"XXX",
        :confirmeddate=>"XXX",
        :copieddate=>"XXX",
        :createddate=>"XXX",
        :docnumber=>"CC/WD 1000:2001",
        :docnumeric=>"1000",
        :doctitle=>"Main Title",
        :doctype=>"Standard",
        :doctype_display=>"Standard",
        :docyear=>"2001",
        :draft=>"3.4",
        :draftinfo=>" (draft 3.4, 2000-01-01)",
        :edition=>"2",
        :implementeddate=>"XXX",
        :issueddate=>"XXX",
        :lang=>"en",
        :metadata_extensions=>{"doctype"=>"standard", "editorialgroup"=>{"committee_type"=>"A", "committee"=>"TC"}},
        :obsoleteddate=>"XXX",
        :publisheddate=>"XXX",
        :publisher=>"CalConnect",
        :receiveddate=>"XXX",
        :revdate=>"2000-01-01",
        :revdate_monthyear=>"January 2000",
        :roles_authors_affiliations=>{"author"=>{"Bedrock Inc."=>["Barney Rubble"]}, "editor"=>{""=>["Fred Flintstone"]}},
        :script=>"Latn",
        :stage=>"Working Draft",
        :stage_display=>"Working Draft",
        :stageabbr=>"WD",
        :tc=>"TC",
        :transmitteddate=>"XXX",
        :unchangeddate=>"XXX",
        :unpublished=>true,
        :updateddate=>"XXX",
        :vote_endeddate=>"XXX",
        :vote_starteddate=>"XXX"}
      OUTPUT
  end

  it "processes pre" do
    input = <<~"INPUT"
      <csd-standard xmlns="https://www.calconnect.org/standards/csd">
        <preface>
          <foreword>
            <pre>ABC</pre>
          </foreword>
        </preface>
      </csd-standard>
    INPUT
    expect(xmlpp(IsoDoc::CC::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*$}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
            #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <pre>ABC</pre>
            </div>
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      OUTPUT
  end

  it "processes keyword" do
    input = <<~"INPUT"
      <csd-standard xmlns="https://www.calconnect.org/standards/csd">
        <preface><foreword>
        <keyword>ABC</keyword>
        </foreword></preface>
      </csd-standard>
    INPUT
    expect(xmlpp(IsoDoc::CC::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*$}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
            #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <span class="keyword">ABC</span>
            </div>
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      OUTPUT
  end

  it "processes simple terms & definitions" do
    input = <<~"INPUT"
      <csd-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="H" obligation="normative"><title>1.<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
            <term id="J">
              <name>1.1.</name>
              <preferred><strong>Term2</strong></preferred>
            </term>
          </terms>
        </sections>
      </csd-standard>
    INPUT
    expect(xmlpp(IsoDoc::CC::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*$}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
            #{HTML_HDR}
            <p class="zzSTDTitle1"/>
            <div id="H">
              <h1>1.&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
              <p class="TermNum" id="J">1.1.</p>
              <p class="Terms" style="text-align:left;"><b>Term2</b></p>
            </div>
          </div>
        </body>
      OUTPUT
  end

  it "rearranges term headers" do
    input = <<~"INPUT"
      <html>
        <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
          <div class="title-section">
            <p>&#160;</p>
          </div>
          <br/>
          <div class="WordSection2">
            <p>&#160;</p>
          </div>
          <br/>
          <div class="WordSection3">
            <p class="zzSTDTitle1"/>
            <div id="H"><h1>1.&#160; Terms and definitions</h1><p>For the purposes of this document,
              the following terms and definitions apply.</p>
              <p class="TermNum" id="J">1.1.</p>
              <p class="Terms" style="text-align:left;">Term2</p>
            </div>
          </div>
        </body>
      </html>
    INPUT
    expect(xmlpp(IsoDoc::CC::HtmlConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <?xml version="1.0"?>
        <html>
          <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
            <div class="title-section">
              <p>&#xA0;</p>
            </div>
            <br/>
            <div class="WordSection2">
              <p>&#xA0;</p>
            </div>
            <br/>
            <div class="WordSection3">
              <p class="zzSTDTitle1"/>
              <div id="H"><h1>1.&#xA0; Terms and definitions</h1>
                <p>For the purposes of this document, the following terms and definitions apply.</p>
                <p class='Terms' style='text-align:left;' id='J'><strong>1.1.</strong>&#xa0;Term2</p>
              </div>
            </div>
          </body>
        </html>
      OUTPUT
  end

  it "processes section names" do
    input = <<~"INPUT"
      <csd-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative">
            <title>Terms, Definitions, Symbols and Abbreviated Terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred>Term2</preferred>
              </term>
            </terms>
            <definitions id="K">
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L">
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative">
          <title>Annex</title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title>Annex A.1a</title>
            </clause>
          </clause>
        </annex>
        <bibliography>
          <references id="R" normative="true" obligation="informative">
            <title>Normative References</title>
          </references>
          <clause id="S" obligation="informative">
            <title>Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </csd-standard>
    INPUT

    expect(xmlpp(strip_guid(IsoDoc::CC::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*$}m, "</body>")))).to be_equivalent_to xmlpp(<<~"OUTPUT")
            <csd-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
              <clause type="toc" id="_" displayorder="1">
              <title depth="1">Table of contents</title>
            </clause>
            <foreword obligation="informative" displayorder="2">
              <title>Foreword</title>
              <p id="A">This is a preamble</p>
            </foreword>
            <introduction id="B" obligation="informative" displayorder="3">
              <title>Introduction</title>
              <clause id="C" inline-header="false" obligation="informative">
                <title depth="2">Introduction Subsection</title>
              </clause>
            </introduction>
          </preface>
          <sections>
            <clause id="D" obligation="normative" displayorder="7">
              <title depth="1">4.<tab/>Scope</title>
              <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" displayorder="5">
              <title depth="1">2.<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
              <terms id="I" obligation="normative">
                <title depth="2">2.1.<tab/>Normal Terms</title>
                <term id="J"><name>2.1.1.</name>
                  <preferred>Term2</preferred>
                </term>
              </terms>
              <definitions id="K"><title>2.2.</title>
                <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
                </dl>
              </definitions>
            </clause>
            <definitions id="L" displayorder="6"><title>3.</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder="8">
              <title depth="1">5.<tab/>Clause 4</title>
              <clause id="N" inline-header="false" obligation="normative">
                <title depth="2">5.1.<tab/>Introduction</title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <title depth="2">5.2.<tab/>Clause 4.2</title>
              </clause>
            </clause>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" displayorder="9">
            <title><strong>Appendix A</strong><br/>(normative)<br/><strong>Annex</strong></title>
            <clause id="Q" inline-header="false" obligation="normative">
              <title depth="2">A.1.<tab/>Annex A.1</title>
              <clause id="Q1" inline-header="false" obligation="normative">
                <title depth="3">A.1.1.<tab/>Annex A.1a</title>
              </clause>
            </clause>
          </annex>
          <bibliography>
            <references id="R" normative="true" obligation="informative" displayorder="4">
              <title depth="1">1.<tab/>Normative References</title>
            </references>
            <clause id="S" obligation="informative" displayorder="10">
              <title depth="1">Bibliography</title>
              <references id="T" normative="false" obligation="informative">
                <title depth="2">Bibliography Subsection</title>
              </references>
            </clause>
          </bibliography>
        </csd-standard>
      OUTPUT
  end

  it "injects JS into blank html" do
    options = [backend: :cc, header_footer: true]
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR}
        <sections/>
      </csd-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *options))))
      .to be_equivalent_to xmlpp(output)
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Source Code Pro})
    expect(html).to match(%r{<main class="main-section"><button})
  end
end
