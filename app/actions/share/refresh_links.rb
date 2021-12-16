#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ShareActions
  ##
  # Refresha i collegamenti del file Excel forecast
  #
  # <div class="lsp">
  #   <h2>Expects:</h2>
  #   - excel (WIN32OLE)<br>
  # </div>
  #
  class RefreshLinks
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    # @!method RefreshLinks(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @expects excel [WIN32OLE]
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      try! do
        workbook_forecast = ctx.excel.Workbooks(Ikigai::Config.file.excel_forecast)
        path = workbook_forecast.Worksheets("Config").Range("C4").value
        refresh_links(workbook_forecast, path)
      end.map_err do |err|
        msg = <<~HEREDOC
          Non riesco ad aggiornare i link nel file del Forecast
          Controllare di aver aggiornato nel file #{Ikigai::Config.file.excel_forecast}
          In Dati => Modifica Collegamenti
          Aggiornare il Collegamento a Programmazione con il mese corretto
        HEREDOC
        ctx.fail_and_return!(
          {message: msg,
           detail: err.message,
           location: "#{__FILE__}:#{__LINE__}"}
        )
      end
    end
  end
end
