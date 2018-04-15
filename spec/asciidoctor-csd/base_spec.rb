require "spec_helper"

RSpec.describe Asciidoctor::Csd do
  it "has a version number" do
    expect(Asciidoctor::Csd::VERSION).not_to be nil
  end

  it "generates output for the Rice document" do
    system "cd spec/examples; rm -f rfc6350.doc; rm -f rfc6350.html; asciidoctor --trace -b iso -r 'asciidoctor-iso' rfc6350.adoc; cd ../.."
    expect(File.exist?("spec/examples/rfc6350.doc")).to be true
    expect(File.exist?("spec/examples/rfc6350.html")).to be true
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

end
