require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-cc"
require "metanorma/cc"
require "isodoc/cc/html_convert"
require "isodoc/cc/word_convert"
require "metanorma/standoc/converter"
require "rspec/matchers"
require "equivalent-xml"
require "htmlentities"
require "metanorma"
require "xml-c14n"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    Dir.mktmpdir("rspec-") do |dir|
      Dir.chdir(dir) { example.run }
    end
  end
end

def metadata(xml)
  xml.sort.to_h.delete_if do |_k, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def presxml_options
  { semanticxmlinsert: "false" }
end

def htmlencode(xml)
  HTMLEntities.new.encode(xml, :hexadecimal)
    .gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n")
    .gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<")
    .gsub(/&#x26;/, "&").gsub(/&#x27;/, "'")
    .gsub(/\\u(....)/) do |_s|
    "&#x#{$1.downcase};"
  end
end

def strip_guid(xml)
  xml.gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
end

ASCIIDOC_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:

HDR

VALIDATING_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:

HDR

def boilerplate_read(file)
  HTMLEntities.new.decode(
    Metanorma::Cc::Converter.new(:cc, {}).boilerplate_file_restructure(file)
    .to_xml.gsub(/<(\/)?sections>/, "<\\1boilerplate>")
      .gsub(/ id="_[^"]+"/, " id='_'"),
  )
end

BOILERPLATE =
  boilerplate_read(
    File.read(File.join(File.dirname(__FILE__), "..", "lib", "metanorma", "cc", "boilerplate.adoc"), encoding: "utf-8")
    .gsub(/\{\{ docyear \}\}/, Date.today.year.to_s)
    .gsub(/<p>/, '<p id="_">')
    .gsub(/\{% if unpublished %\}.+?\{% endif %\}/m, "")
    .gsub(/\{% if ip_notice_received %\}\{% else %\}not\{% endif %\}/m, ""),
  )

BOILERPLATE_LICENSE = <<~BOILERPLATE.freeze
  <license-statement>
    <clause id="_" obligation="normative">
      <title>Warning for Drafts</title>
      <p id='_'>
        This document is not a CalConnect Standard. It is distributed for
        review and comment, and is subject to change without notice and may
        not be referred to as a Standard. Recipients of this draft are invited
        to submit, with their comments, notification of any relevant patent
        rights of which they are aware and to provide supporting
        documentation.
      </p>
    </clause>
  </license-statement>
BOILERPLATE

BLANK_HDR = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <csd-standard xmlns="https://www.metanorma.org/ns/csd" type="semantic" version="#{Metanorma::Cc::VERSION}">
  <bibdata type="standard">
   <title language="en" format="text/plain">Document title</title>
    <docidentifier primary="true" type="CalConnect">CC :#{Time.now.year}</docidentifier>
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
   </status>

    <copyright>
      <from>#{Time.new.year}</from>
      <owner>
        <organization>
          <name>CalConnect</name>
        </organization>
      </owner>
    </copyright>
    <ext>
     <doctype>standard</doctype>
     <flavor>cc</flavor>
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
           <presentation-metadata>
             <name>PDF TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
         </metanorma-extension>
  #{BOILERPLATE}
HDR

HTML_HDR = <<~"HDR".freeze
  <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
    <div class="title-section">
      <p>&#160;</p>
    </div>
    <br/>
    <div class="prefatory-section">
      <p>&#160;</p>
    </div>
    <br/>
    <div class="main-section">
HDR

def mock_pdf
  allow(::Mn2pdf).to receive(:convert) do |url, output, _c, _d|
    FileUtils.cp(url.delete('"'), output.delete('"'))
  end
end
