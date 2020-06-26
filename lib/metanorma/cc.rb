require_relative "./cc/processor"

module Metanorma
  module CC

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
