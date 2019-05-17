require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Csd do

  it "Warns of illegal doctype" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(/pizza is not a legal document type/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :doctype: pizza

  text
  INPUT
end

  it "Warns of illegal status" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(/pizza is not a recognised status/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: pizza

  text
  INPUT
end

  it "does not validate section ordering if the docuemnt is advisory" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.not_to output(%r{only one Symbols and Abbreviated Terms section in the standard}).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :doctype: advisory


  == Terms and Abbreviations

  === Symbols and Abbreviated Terms

  == Symbols and Abbreviated Terms
  INPUT
  end

it "Style warning if two Symbols and Abbreviated Terms sections" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{only one Symbols and Abbreviated Terms section in the standard}).to_stderr
  #{VALIDATING_BLANK_HDR}

  == Terms and Abbreviations

  === Symbols and Abbreviated Terms

  == Symbols and Abbreviated Terms
  INPUT
end

it "Style warning if Symbols and Abbreviated Terms contains extraneous matter" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Symbols and Abbreviated Terms can only contain a definition list}).to_stderr
  #{VALIDATING_BLANK_HDR}

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
end

it "Warning if do not start with scope or introduction" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Prefatory material must be followed by \(clause\) Scope}).to_stderr
  #{VALIDATING_BLANK_HDR}

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
end

it "Warning if introduction not followed by scope" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Prefatory material must be followed by \(clause\) Scope}).to_stderr
  #{VALIDATING_BLANK_HDR}

  .Foreword 
  Foreword

  == Introduction

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
end

it "Warning if normative references not followed by terms and definitions" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Normative References must be followed by Terms and Definitions}).to_stderr
  #{VALIDATING_BLANK_HDR}

  .Foreword 
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
end

it "Warning if there are no clauses in the document" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Document must contain clause after Terms and Definitions}).to_stderr
  #{VALIDATING_BLANK_HDR}

  .Foreword 
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Symbols and Abbreviated Terms

  INPUT
end

it "Warning if scope occurs after Terms and Definitions" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Scope must occur before Terms and Definitions}).to_stderr
  #{VALIDATING_BLANK_HDR}

  .Foreword
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Scope

  INPUT
end

it "Warning if scope occurs after Terms and Definitions" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Scope must occur before Terms and Definitions}).to_stderr
  #{VALIDATING_BLANK_HDR}

  .Foreword
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Clause

  == Scope

  INPUT
end

it "Warning if Symbols and Abbreviated Terms does not occur immediately after Terms and Definitions" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Only annexes and references can follow clauses}).to_stderr
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
end

it "Warning if no normative references" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Document must include \(references\) Normative References}).to_stderr
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
end

it "Warning if final section is not named Bibliography" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{There are sections after the final Bibliography}).to_stderr
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
end

it "Warning if final section is not styled Bibliography" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true) }.to output(%r{Section not marked up as \[bibliography\]!}).to_stderr
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
end
end
