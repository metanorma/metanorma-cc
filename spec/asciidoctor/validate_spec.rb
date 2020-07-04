require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::CC do

  it "Warns of illegal doctype" do
      FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :doctype: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a legal document type"
end

  it "Warns of illegal status" do
      FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised status"
end

  it "does not validate section ordering if the docuemnt is advisory" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :doctype: advisory


  == Terms and Abbreviations

  === Symbols and Abbreviated Terms

  == Symbols and Abbreviated Terms
  INPUT
    expect(File.read("test.err")).not_to include "only one Symbols and Abbreviated Terms section in the standard"
  end

it "Style warning if two Symbols and Abbreviated Terms sections" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  == Terms and Abbreviations

  === Symbols and Abbreviated Terms

  == Symbols and Abbreviated Terms
  INPUT
    expect(File.read("test.err")).to include "Only one Symbols and Abbreviated Terms section in the standard"
end

it "Style warning if Symbols and Abbreviated Terms contains extraneous matter" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
    expect(File.read("test.err")).to include "Symbols and Abbreviated Terms can only contain a definition list"
end

it "Warning if do not start with scope or introduction" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  Foreword 

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
    expect(File.read("test.err")).to include "Prefatory material must be followed by (clause) Scope"
end

it "Warning if introduction not followed by scope" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  .Foreword 
  Foreword

  == Introduction

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
    expect(File.read("test.err")).to include "Prefatory material must be followed by (clause) Scope"
end

it "Warning if normative references not followed by terms and definitions" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  .Foreword 
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
    expect(File.read("test.err")).to include "Normative References must be followed by Terms and Definitions"
end

it "Warning if there are no clauses in the document" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  .Foreword 
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Symbols and Abbreviated Terms

  INPUT
    expect(File.read("test.err")).to include "Document must contain clause after Terms and Definitions"
end

it "Warning if scope occurs after Terms and Definitions" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  .Foreword
  Foreword

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Clause

  == Scope

  INPUT
    expect(File.read("test.err")).to include "Scope must occur before Terms and Definitions"
end

it "Warning if Symbols and Abbreviated Terms does not occur immediately after Terms and Definitions" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  .Foreword
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Clause

  == Symbols and Abbreviated Terms

  INPUT
    expect(File.read("test.err")).to include "Only annexes and references can follow clauses"
end

it "Warning if no normative references" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  .Foreword
  Foreword

  == Scope

  == Terms and Definitions

  == Clause

  [appendix]
  == Appendix A

  [appendix]
  == Appendix B

  [appendix]
  == Appendix C

  INPUT
    expect(File.read("test.err")).to include "Document must include (references) Normative References"
end

it "Warning if final section is not named Bibliography" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  .Foreword
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Clause

  [appendix]
  == Appendix A

  [appendix]
  == Appendix B

  [bibliography]
  == Bibliography

  [bibliography]
  == Appendix C

  INPUT
    expect(File.read("test.err")).to include "There are sections after the final Bibliography"
end

it "Warning if final section is not styled Bibliography" do
      FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :cc, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  .Foreword
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Clause

  [appendix]
  == Appendix A

  [appendix]
  == Appendix B

  == Bibliography

  INPUT
    expect(File.read("test.err")).to include "Section not marked up as [bibliography]!"
end
end
