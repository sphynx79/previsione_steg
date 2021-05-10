#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ReportActions
  # Chiama una funzione Excel per salvare su PDF lo sheet Forecast
  class SavePdf
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action
    # @expects arg[Type] Description
    # @promises arg[Type] Description
    # expects  :..
    # promises :..

    # @!method SavePdf
    #   @yield Description
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      feedback = save_pdf(ctx.path_pdf_report)
      ctx.fail_and_return!("Non sono riuscito a salvare il file \"#{ctx.path_pdf_report}\"") unless feedback
    end

    # private_class_method :..
  end
end
