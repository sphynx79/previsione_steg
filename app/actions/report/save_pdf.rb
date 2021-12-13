#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ReportActions
  ##
  # Chiama una funzione Excel per salvare su PDF lo sheet Forecast
  #
  # <div class="lsp">
  #   <h2>Expects:</h2>
  #   - path_pdf_report (String) Path dove salvare il PDF<br>
  # </div>
  #
  class SavePdf
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    # @!method SavePdf(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @expects path_pdf_report [String] Path dove salvare i PDF
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      feedback = save_pdf(ctx.path_pdf_report)
      ctx.fail_and_return!("Non sono riuscito a salvare il file \"#{ctx.path_pdf_report}\" | #{__FILE__}:#{__LINE__}") unless feedback
    end
  end
end
