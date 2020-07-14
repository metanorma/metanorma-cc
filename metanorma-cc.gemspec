lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metanorma/cc/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-cc"
  spec.version       = Metanorma::CC::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "metanorma-cc lets you write CalConnect standards in AsciiDoc."
  spec.description   = <<~DESCRIPTION
    metanorma-cc lets you write CalConnect standards in AsciiDoc syntax.

    This gem is in active development.

    Formerly known as asciidoctor-csd, metanorma-csd.
  DESCRIPTION

  spec.homepage      = "https://github.com/metanorma/metanorma-cc"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_dependency "metanorma-standoc", "~> 1.4.0"
  # spec.add_dependency "isodoc", "~> 1.1.0"

  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "sassc", "2.4.0"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "= 0.54.0"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
end
