# frozen_string_literal: true

require "metanorma/html"

module Metanorma
  module Cc
    # HTML format adapter slice for the CC flavor: binds the flavor's
    # document root to the standard document rendering.
    module Html
      class Renderer < Metanorma::Html::StandardRenderer
        register_render "Metanorma::Cc::Document::Root", :render_standard_document
      end
    end
  end
end
