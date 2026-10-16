require "spec_helper"

RSpec.describe Metanorma::Cc do
  it "registers the cc flavor with the core flavor table" do
    skip "metanorma-core predates the flavor table" unless defined?(Metanorma::Core::Flavors)

    flavor = Metanorma::Core::Flavors.find(:cc)
    expect(flavor).not_to be_nil
    expect(flavor.gem).to eq("metanorma-cc")
    expect(flavor.model_root).to eq(Metanorma::Cc::Document::Root)
  end

  it "creates the cc_document lutaml register" do
    Metanorma::Cc::Registers.setup
    expect(Lutaml::Model::GlobalRegister.lookup(:cc_document)).not_to be_nil
  end

  it "parses the unified semantic root into the cc model" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" flavor="cc">
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title id="_">Scope</title>
            <p id="_">This document establishes the provisions.</p>
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::Cc::Document::Root.from_xml(xml)
    expect(root).to be_a(Metanorma::Cc::Document::Root)
    expect(root.sections.first).to be_a(Metanorma::Standoc::Document::Sections::Sections)
    expect(root.sections.first.clause.first.title.text).to eq(["Scope"])
  end

  it "resolves the html renderer through the harness" do
    skip "metanorma-core predates the flavor table" unless defined?(Metanorma::Core::Flavors)

    root = Metanorma::Cc::Document::Root.new
    flavor = Metanorma::Core::Flavors.find(:cc)
    expect(flavor.renderer_for(:html, root)).to eq(Metanorma::Html::StandardRenderer)
  end
end
