require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Cc do
  it "processes default metadata" do
    csdc = IsoDoc::Cc::HtmlConvert.new({})
    docxml, = csdc.convert_init(<<~INPUT, "test", true)
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
    expect(metadata(csdc.info(docxml, nil)))
      .to be_equivalent_to (
        { accesseddate: "XXX",
          adapteddate: "XXX",
          agency: "CalConnect",
          announceddate: "XXX",
          authors: ["Fred Flintstone", "Barney Rubble"],
          authors_affiliations: { "" => ["Fred Flintstone"],
                                  "Bedrock Inc." => ["Barney Rubble"] },
          circulateddate: "XXX",
          confirmeddate: "XXX",
          copieddate: "XXX",
          correcteddate: "XXX",
          createddate: "XXX",
          docnumber: "CC/WD 1000:2001",
          docnumeric: "1000",
          doctitle: "Main Title",
          doctype: "Standard",
          doctype_display: "Standard",
          docyear: "2001",
          draft: "3.4",
          draftinfo: " (draft 3.4, 2000-01-01)",
          edition: "2",
          implementeddate: "XXX",
          issueddate: "XXX",
          lang: "en",
          metadata_extensions: { "doctype" => "standard",
                                 "editorialgroup" => {
                                   "committee_type" => "A", "committee" => "TC"
                                 } },
          obsoleteddate: "XXX",
          publisheddate: "XXX",
          publisher: "CalConnect",
          receiveddate: "XXX",
          revdate: "2000-01-01",
          revdate_monthyear: "January 2000",
          roles_authors_affiliations: {
            "author" => { "Bedrock Inc." => ["Barney Rubble"] }, "editor" => { "" => ["Fred Flintstone"] }
          },
          script: "Latn",
          stable_untildate: "XXX",
          stage: "Working Draft",
          stage_display: "Working Draft",
          stageabbr: "WD",
          tc: "TC",
          transmitteddate: "XXX",
          unchangeddate: "XXX",
          unpublished: true,
          updateddate: "XXX",
          vote_endeddate: "XXX",
          vote_starteddate: "XXX" }
      )
  end

  it "rearranges term headers" do
    input = <<~INPUT
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
            <div id="H"><h1>1.&#160; Terms and definitions</h1><p>For the purposes of this document,
              the following terms and definitions apply.</p>
              <p class="TermNum" id="J">1.1.</p>
              <p class="Terms" style="text-align:left;">Term2</p>
            </div>
          </div>
        </body>
      </html>
    INPUT
    expect(Xml::C14n.format(IsoDoc::Cc::HtmlConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
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
    input = <<~INPUT
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
                <preferred><expression><name>Term2</name></expression></preferred>
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

    output = <<~OUTPUT
          <csd-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title depth="1">Contents</fmt-title>
            </clause>
            <foreword obligation="informative" displayorder="2" id="_">
               <title id="_">Foreword</title>
               <fmt-title depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p id="A">This is a preamble</p>
            </foreword>
            <introduction id="B" obligation="informative" displayorder="3">
               <title id="_">Introduction</title>
               <fmt-title depth="1">
                  <semx element="title" source="_">Introduction</semx>
               </fmt-title>
               <clause id="C" inline-header="false" obligation="informative">
                  <title id="_">Introduction Subsection</title>
                  <fmt-title depth="2">
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
               </clause>
            </introduction>
         </preface>
         <sections>
            <clause id="D" obligation="normative" displayorder="7">
               <title id="_">Scope</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="D">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Scope</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="D">4</semx>
               </fmt-xref-label>
               <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" displayorder="5">
               <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="H">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">2</semx>
               </fmt-xref-label>
               <terms id="I" obligation="normative">
                  <title id="_">Normal Terms</title>
                  <fmt-title depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Normal Terms</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="H">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                  </fmt-xref-label>
                  <term id="J">
                     <fmt-name>
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="H">2</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="I">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="J">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                        </span>
                     </fmt-name>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="H">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="J">1</semx>
                     </fmt-xref-label>
              <preferred id="_">
                 <expression>
                    <name>Term2</name>
                 </expression>
              </preferred>
              <fmt-preferred>
                 <p>
                    <semx element="preferred" source="_">
                       <strong>Term2</strong>
                    </semx>
                 </p>
              </fmt-preferred>
                  </term>
               </terms>
               <definitions id="K">
                  <title id="_">Symbols</title>
                  <fmt-title depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="K">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Symbols</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="H">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="K">2</semx>
                  </fmt-xref-label>
                  <dl>
                     <dt>Symbol</dt>
                     <dd>Definition</dd>
                  </dl>
               </definitions>
            </clause>
            <definitions id="L" displayorder="6">
               <title id="_">Symbols</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="L">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Symbols</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="L">3</semx>
               </fmt-xref-label>
               <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
               </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder="8">
               <title id="_">Clause 4</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 4</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="M">5</semx>
               </fmt-xref-label>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">5</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="N">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </fmt-xref-label>
               </clause>
               <clause id="O" inline-header="false" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">5</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="O">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Clause 4.2</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O">2</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
            <references id="R" normative="true" obligation="informative" displayorder="4">
               <title id="_">Normative References</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="R">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="R">1</semx>
               </fmt-xref-label>
            </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
            <title id="_">
               <strong>Annex</strong>
            </title>
            <fmt-title>
               <strong>
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Appendix</span>
                     <semx element="autonum" source="P">A</semx>
                  </span>
               </strong>
               <br/>
               <span class="fmt-obligation">(normative)</span>
               <span class="fmt-caption-delim">
                  <br/>
               </span>
               <semx element="title" source="_">
                  <strong>Annex</strong>
               </semx>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Appendix</span>
               <semx element="autonum" source="P">A</semx>
            </fmt-xref-label>
            <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
               <title id="_">Annex A.1</title>
               <fmt-title depth="2">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Annex A.1</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Appendix</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
               </fmt-xref-label>
               <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                  <title id="_">Annex A.1a</title>
                  <fmt-title depth="3">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="P">A</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Annex A.1a</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Appendix</span>
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q1">1</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
         </annex>
         <bibliography>
            <clause id="S" obligation="informative" displayorder="10">
               <title id="_">Bibliography</title>
               <fmt-title depth="1">
                  <semx element="title" source="_">Bibliography</semx>
               </fmt-title>
               <references id="T" normative="false" obligation="informative">
                  <title id="_">Bibliography Subsection</title>
                  <fmt-title depth="2">
                     <semx element="title" source="_">Bibliography Subsection</semx>
                  </fmt-title>
               </references>
            </clause>
         </bibliography>
      </csd-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Cc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
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
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *options))))
      .to be_equivalent_to Xml::C14n.format(output)
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Source Code Pro})
    expect(html).to match(%r{<main class="main-section"><button})
  end

  it "processes unordered lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause type="toc" id="_" displayorder="1"> <fmt-title depth="1">Table of contents</fmt-title> </clause>
          <foreword displayorder="2" id="fwd"><fmt-title>Foreword</fmt-title>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddb"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">Level 1</p>
        </li>
        <li>
          <p id="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 2</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 3</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 4</p>
        </li>
        </ul>
        </li>
        </ul>
        </li>
          </ul>
        </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <foreword displayorder="1" id="fwd">
               <title id="_">Foreword</title>
               <fmt-title depth="1">Foreword</fmt-title>
               <ul id="_" keep-with-next="true" keep-lines-together="true">
                  <name id="_">Caption</name>
                  <fmt-name>
                     <semx element="name" source="_">Caption</semx>
                  </fmt-name>
                  <li>
                     <fmt-name>
                        <semx element="autonum" source="">—</semx>
                     </fmt-name>
                     <p id="_">Level 1</p>
                  </li>
                  <li>
                     <fmt-name>
                        <semx element="autonum" source="">—</semx>
                     </fmt-name>
                     <p id="_">deletion of 4.3.</p>
                     <ul id="_" keep-with-next="true" keep-lines-together="true">
                        <li>
                           <fmt-name>
                              <semx element="autonum" source="">—</semx>
                           </fmt-name>
                           <p id="_">Level 2</p>
                           <ul id="_" keep-with-next="true" keep-lines-together="true">
                              <li>
                                 <fmt-name>
                                    <semx element="autonum" source="">—</semx>
                                 </fmt-name>
                                 <p id="_">Level 3</p>
                                 <ul id="_" keep-with-next="true" keep-lines-together="true">
                                    <li>
                                       <fmt-name>
                                          <semx element="autonum" source="">—</semx>
                                       </fmt-name>
                                       <p id="_">Level 4</p>
                                    </li>
                                 </ul>
                              </li>
                           </ul>
                        </li>
                     </ul>
                  </li>
               </ul>
            </foreword>
            <clause type="toc" id="_" displayorder="2">
               <fmt-title depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Cc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes ordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword id="_" displayorder="2">
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="alphabet"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
          </ol>
        <ol id="A">
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">Level 1</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 2</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 3</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 4</p>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title depth="1">Contents</fmt-title>
            </clause>
            <foreword id="_" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <ol id="_" type="alphabet" keep-with-next="true" keep-lines-together="true" autonum="1">
                  <name id="_">Caption</name>
                  <fmt-name>
                     <semx element="name" source="_">Caption</semx>
                  </fmt-name>
                  <li id="_">
                     <fmt-name>
                        <semx element="autonum" source="_">a</semx>
                        <span class="fmt-label-delim">)</span>
                     </fmt-name>
                     <p id="_">Level 1</p>
                  </li>
               </ol>
               <ol id="A" type="alphabet">
                  <li id="_">
                     <fmt-name>
                        <semx element="autonum" source="_">a</semx>
                        <span class="fmt-label-delim">)</span>
                     </fmt-name>
                     <p id="_">Level 1</p>
                  </li>
                  <li id="_">
                     <fmt-name>
                        <semx element="autonum" source="_">b</semx>
                        <span class="fmt-label-delim">)</span>
                     </fmt-name>
                     <p id="_">Level 1</p>
                     <ol type="arabic">
                        <li id="_">
                           <fmt-name>
                              <semx element="autonum" source="_">1</semx>
                              <span class="fmt-label-delim">)</span>
                           </fmt-name>
                           <p id="_">Level 2</p>
                           <ol type="roman">
                              <li id="_">
                                 <fmt-name>
                                    <semx element="autonum" source="_">i</semx>
                                    <span class="fmt-label-delim">)</span>
                                 </fmt-name>
                                 <p id="_">Level 3</p>
                                 <ol type="alphabet_upper">
                                    <li id="_">
                                       <fmt-name>
                                          <semx element="autonum" source="_">A</semx>
                                          <span class="fmt-label-delim">.</span>
                                       </fmt-name>
                                       <p id="_">Level 4</p>
                                    </li>
                                 </ol>
                              </li>
                           </ol>
                        </li>
                     </ol>
                  </li>
               </ol>
            </foreword>
         </preface>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Cc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end
