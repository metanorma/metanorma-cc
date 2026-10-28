Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# Canonical line: the relaton 3 finals over the α engine line.
gem "metanorma-generic", github: "metanorma/metanorma-generic", branch: "main"
gem "metanorma-standoc", "~> 3.5.1.pre.alpha"
gem "metanorma-core", "~> 0.2.5.pre.alpha" # published flavor/taste table (metanorma-core#18)
gem "metanorma-document", "~> 0.5.2.pre.alpha"
gem "isodoc", "~> 3.7.4.pre.alpha"
gem "metanorma-mirror", github: "metanorma/metanorma-mirror", branch: "main"
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "main"
gem "relaton", "~> 3.0"
gem "relaton-render", "~> 3.0"
gem "pubid", "~> 2.0"
gem "lutaml-model", "~> 0.8" # relaton 3.x declares singular_tolerance (needs 0.8.113+)
gem "sassc-embedded", "~> 1.80"
gem "rake", ">= 13.0"

eval_gemfile("Gemfile.devel") rescue nil
