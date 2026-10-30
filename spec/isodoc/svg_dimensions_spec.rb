# frozen_string_literal: true

require "rexml/document"
require "rexml/xpath"
require "open3"
require "tmpdir"
require "mn2pdf"

RSpec.describe "linked SVG dimensions" do
  def dimensions(element)
    %w[width height].map { |name| element.attributes[name] }
  end

  before(:context) do
    stylesheet = ENV.fetch("CC_SVG_TEST_STYLESHEET") do
      File.expand_path("../../lib/isodoc/cc/cc.standard.xsl", __dir__)
    end
    source = REXML::Document.new(File.read(stylesheet))
    namespaces = { "xsl" => "http://www.w3.org/1999/XSL/Transform",
                   "fo" => "http://www.w3.org/1999/XSL/Format" }
    branch = REXML::XPath.first(source,
      "//xsl:template[@name='image_svg']/xsl:choose/xsl:when", namespaces)
    block = REXML::XPath.first(branch, "fo:block", namespaces)
    variables = REXML::XPath.match(block, "xsl:variable", namespaces)
    column = REXML::XPath.match(block, "fo:table/fo:table-column", namespaces)[1]
    container = REXML::XPath.first(block, ".//fo:block-container", namespaces).deep_clone
    container.children.to_a.each { |child| container.delete(child) }

    # Execute the production variables and FO attributes with the same Xalan
    # implementation as mn2pdf; do not reimplement their arithmetic in Ruby.
    driver = <<~XSL
      <xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:java="http://xml.apache.org/xalan/java"
        xmlns:fo="http://www.w3.org/1999/XSL/Format">
        <xsl:variable name="width_effective_px" select="10000"/>
        <xsl:variable name="height_effective_px" select="10000"/>
        <xsl:template match="/">
          <results><xsl:for-each select="cases/case">
            <case id="{@id}"><xsl:for-each select="*[local-name()='svg']">
              <xsl:if test="#{branch.attributes['test']}">
                #{variables.map(&:to_s).join}
                <normalized width="{$width}" height="{$height}"/>
                #{column}#{container}
              </xsl:if>
            </xsl:for-each></case>
          </xsl:for-each></results>
        </xsl:template>
      </xsl:stylesheet>
    XSL
    fixture = File.expand_path("../examples/svg/linked_dimensions.xml", __dir__)
    @dimensions = Dir.mktmpdir("cc-svg-dimensions") do |dir|
      xsl = File.join(dir, "dimensions.xsl")
      output = File.join(dir, "dimensions.xml")
      File.write(xsl, driver)
      stdout, stderr, status = Open3.capture3("java", "-cp",
        Jvm::MN2PDF_JAR_PATH.to_s, "org.apache.xalan.xslt.Process",
        "-IN", fixture, "-XSL", xsl, "-OUT", output)
      raise "Xalan failed: #{stdout}\n#{stderr}" unless status.success? && File.file?(output)

      REXML::Document.new(File.read(output))
    end
  end

  { "unitless" => %w[364 96 364px 96px],
    "pixels" => %w[364 96 364px 96px],
    "decimal" => %w[184.5 96.25 185px 96px],
    "mixed" => %w[364 96 364px 96px],
    "whitespace" => %w[364 96 364px 96px] }.each do |name, values|
    it "calculates numeric FO dimensions for #{name} SVG lengths" do
      result = @dimensions.elements["results/case[@id='#{name}']"]
      expect(dimensions(result.elements["normalized"])).to eq(values.first(2))
      expect(result.elements["fo:table-column"].attributes["column-width"]).to eq(values[2])
      expect(dimensions(result.elements["fo:block-container"])).to eq(values.last(2))
    end
  end

  %w[other_units invalid].each do |name|
    it "does not accept #{name} as pixel lengths" do
      result = @dimensions.elements["results/case[@id='#{name}']"]
      expect(result.elements["fo:table-column"].attributes["column-width"]).to eq("NaNpx")
      expect(dimensions(result.elements["fo:block-container"])).to eq(%w[NaNpx NaNpx])
    end
  end
end
