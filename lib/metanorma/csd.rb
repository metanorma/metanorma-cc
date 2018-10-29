require_relative "./csd/processor"

module Metanorma
  module Csd

    DOCSUFFIX = {
      "standard" => "",
      "directive" => "DIR",
      "guide" => "Guide",
      "specification" => "S",
      "report" => "R",
      "amendment" => "Amd",
      "technical-corrigendum" => "Cor",
      "administrative" => "A",
      "advisory" => "Adv",
    }

    DOCSTATUS = {
      "working-draft" => "WD",
      "committee-draft" => "CD",
      "draft-standard" => "DS",
      "final-draft" => "FDS",
      "published" => "",
      "cancelled" => "",
      "withdrawn" => "",
    }

  end
end
