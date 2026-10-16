Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# Canonical line: the relaton 3.x prerelease monogem over the current
# gem mains (the released generic/standoc line caps relaton at 2.x).
gem "metanorma-generic", github: "metanorma/metanorma-generic", branch: "main"
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "main"
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "main"
gem "isodoc", github: "metanorma/isodoc", branch: "main"
gem "metanorma-mirror", github: "metanorma/metanorma-mirror", branch: "main"
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "main"
gem "relaton", "~> 3.0.0.pre.alpha"
gem "relaton-render", "~> 3.0.0.pre.alpha"
gem "pubid", "~> 2.0.0.pre.alpha"
gem "lutaml-model", "0.8.107"
gem "leptris", "1.9.356.0"
gem "moxml", "~> 0.5.84", "< 0.5.138"
gem "sassc-embedded", "~> 1.80"
gem "rake", ">= 13.0"

eval_gemfile("Gemfile.devel") rescue nil
